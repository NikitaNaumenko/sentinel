defmodule Sentinel.Checks do
  @moduledoc """
  The Checks context.
  """

  import Ecto.Query, warn: false

  alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.MonitorWorker
  alias Sentinel.Checks.UseCases.CheckCertificate
  alias Sentinel.Repo

  require Logger

  @doc """
  Returns the list of monitors.

  ## Examples

      iex> list_monitors()
      [%Monitor{}, ...]

  """
  def list_monitors do
    Repo.all(Monitor)
  end

  @doc """
  Gets a single monitor.

  Raises `Ecto.NoResultsError` if the Monitor does not exist.

  ## Examples

      iex> get_monitor!(123)
      %Monitor{}

      iex> get_monitor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_monitor!(id), do: Repo.get!(Monitor, id)

  @doc """
  Creates a monitor.

  ## Examples

      iex> create_monitor(%{field: value})
      {:ok, %Monitor{}}

      iex> create_monitor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_monitor(attrs \\ %{}) do
    certificate = CheckCertificate.call(attrs["url"])

    %Monitor{}
    |> Monitor.changeset(Map.put(attrs, "certificates", [certificate]))
    |> Repo.insert()
    |> case do
      {:ok, monitor} ->
        {:ok, _pid} = MonitorWorker.start_link(monitor)
        {:ok, monitor}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:error, changeset}
    end
  end

  @doc """
  Updates a monitor.

  ## Examples

      iex> update_monitor(monitor, %{field: new_value})
      {:ok, %Monitor{}}

      iex> update_monitor(monitor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_monitor(%Monitor{} = monitor, attrs) do
    monitor
    |> Monitor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a monitor.

  ## Examples

      iex> delete_monitor(monitor)
      {:ok, %Monitor{}}

      iex> delete_monitor(monitor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_monitor(%Monitor{} = monitor) do
    Repo.delete(monitor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking monitor changes.

  ## Examples

      iex> change_monitor(monitor)
      %Ecto.Changeset{data: %Monitor{}}

  """
  def change_monitor(%Monitor{} = monitor, attrs \\ %{}) do
    Monitor.changeset(monitor, attrs)
  end

  # TODO: Build normal topic build function
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Sentinel.PubSub, topic)
    Logger.info("Subscribed to #{topic}")
  end

  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(Sentinel.PubSub, topic)
    Logger.info("Unsubscribed from #{topic}")
  end

  def broadcast(topic, monitor) do
    Phoenix.PubSub.broadcast(Sentinel.PubSub, topic, {:msg, monitor})
  end

  def check_certificate(url), do: CheckCertificate.call(url)

  # @spec topic(Product.t()) :: String.t()
  # defp topic(monitor) do
  #   "monitor-#{monitor.account_id}-#{monitor.id}"
  # end
end
