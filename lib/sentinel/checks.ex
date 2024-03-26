defmodule Sentinel.Checks do
  @moduledoc """
  The Checks context.
  """

  import Ecto.Query, warn: false

  alias Sentinel.Checks.Certificate
  alias Sentinel.Checks.Check
  alias Sentinel.Checks.Incident
  alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.MonitorWorker
  alias Sentinel.Checks.NotificationRule
  alias Sentinel.Checks.UseCases.CheckCertificate
  alias Sentinel.Checks.UseCases.CreateMonitor
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
  def get_monitor!(id), do: Monitor |> Repo.get!(id) |> Repo.preload([:account, :notification_rule])

  def check_certificate(url), do: CheckCertificate.call(url)

  def start_monitor(monitor) do
    MonitorWorker.start_link(monitor)
  end

  def create_monitor(attrs) do
    CreateMonitor.call(attrs)
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

  def toggle_monitor(monitor) do
    monitor
    |> Ecto.Changeset.change(%{state: toggle_monitor_state(monitor)})
    |> Repo.update()
  end

  defp toggle_monitor_state(%Monitor{state: :active}), do: :disabled
  defp toggle_monitor_state(%Monitor{state: :disabled}), do: :active

  def calculate_uptime(%Monitor{id: monitor_id}) do
    from(c in Check,
      where: [monitor_id: ^monitor_id],
      group_by: :result,
      select: {c.result, fragment("count(*) * 100.0 / sum(count(*)) over()")}
    )
    |> Repo.all()
    |> Keyword.get(:success, 0)
    |> Decimal.round(2)
  end

  def avg_response_time(%Monitor{id: monitor_id}) do
    from(c in Check, where: [monitor_id: ^monitor_id])
    |> Repo.aggregate(:avg, :duration)
    |> case do
      nil ->
        0

      avg ->
        avg
        |> Decimal.round()
        |> Decimal.to_integer()
    end
  end

  def count_incidents(%Monitor{id: monitor_id}) do
    Repo.aggregate(
      from(c in Check, where: [monitor_id: ^monitor_id, result: :failure]),
      :count,
      :id
    )
  end

  def calculate_uptime_sequence(%Monitor{id: monitor_id}) do
    last_failed =
      from(c in Check,
        where: [result: :failure, monitor_id: ^monitor_id],
        order_by: [desc: :id],
        limit: 1,
        select: c.id
      )

    from(c in Check,
      where: [result: :success, monitor_id: ^monitor_id],
      where: c.id > subquery(last_failed),
      order_by: [asc: :id],
      limit: 1,
      select: fragment("EXTRACT(epoch FROM LOCALTIMESTAMP - inserted_at)")
    )
    |> Repo.one()
    |> case do
      nil ->
        0

      avg ->
        avg
        |> Decimal.round()
        |> Decimal.to_integer()
    end
    |> Decimal.round()
    |> Decimal.to_integer()
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

  def last_certificate(%Monitor{id: monitor_id}) do
    Repo.one(from(c in Certificate, where: c.monitor_id == ^monitor_id, order_by: [desc: :id], limit: 1))
  end

  def list_checks_for_uptime_stats(%Monitor{id: monitor_id}) do
    # TODO: set 1
    yesterday = DateTime.add(DateTime.utc_now(), -10, :day)

    Repo.all(
      from(c in Check,
        where: [monitor_id: ^monitor_id],
        where: c.inserted_at > ^yesterday,
        select: %{result: c.result, inserted_at: c.inserted_at}
      )
    )
  end

  def list_checks_for_response_times(%Monitor{id: monitor_id}) do
    # TODO: set 1
    yesterday = DateTime.add(DateTime.utc_now(), -10, :day)

    Repo.all(
      from(c in Check,
        where: [monitor_id: ^monitor_id],
        where: c.inserted_at > ^yesterday,
        select: %{duration: c.duration, inserted_at: c.inserted_at}
      )
    )
  end

  def last_five_checks(%Monitor{id: monitor_id}) do
    Repo.all(
      from(c in Check,
        where: [monitor_id: ^monitor_id],
        order_by: [desc: :id],
        limit: 5
      )
    )
  end

  def get_check(id) do
    Repo.get(Check, id)
  end

  def toggle_via(id, attr, value) do
    NotificationRule
    |> Repo.get(id)
    |> Ecto.Changeset.change(%{String.to_existing_atom(attr) => !value})
    |> Repo.update()
  end

  def update_notification_rule(%NotificationRule{} = notification_rule, attrs) do
    notification_rule
    |> NotificationRule.changeset(attrs)
    |> Repo.update()
  end

  def get_incident(id) do
    Repo.get(Incident, id)
  end

  # @spec topic(Product.t()) :: String.t()
  # defp topic(monitor) do
  #   "monitor-#{monitor.account_id}-#{monitor.id}"
  # end
end
