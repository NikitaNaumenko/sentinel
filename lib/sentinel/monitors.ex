defmodule Sentinel.Monitors do
  @moduledoc """
  The Monitors context.
  """

  import Ecto.Query, warn: false

  alias Sentinel.Monitors.Certificate
  alias Sentinel.Monitors.Check
  alias Sentinel.Monitors.Incident
  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorWorker
  alias Sentinel.Monitors.NotificationRule
  alias Sentinel.Monitors.UseCases.CheckCertificate
  alias Sentinel.Monitors.UseCases.CreateMonitor
  alias Sentinel.Repo

  require Logger

  @doc """
  Returns the list of monitors.

  ## Examples

      iex> list_monitors()
      [%Monitor{}, ...]

  """
  def list_monitors(account_id) do
    Monitor
    |> where([m], m.account_id == ^account_id and m.state != :deleted)
    |> Repo.all()
  end

  def all_monitors do
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
  def get_monitor!(id) do
    Repo.one(
      from(m in Monitor,
        where: m.state != :deleted,
        where: m.id == ^id,
        preload: [:account, :escalation_policy]
      )
    )
  end

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
  def delete_monitor(id) do
    id
    |> get_monitor!()
    |> Ecto.Changeset.change(%{state: :deleted})
    |> Repo.update()
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

  def create_monitors_from_file(filepath, account_id) do
    {:ok, process_monitors_file(Path.extname(filepath), filepath, account_id)}
  end

  defp process_monitors_file(".json", filepath, account_id) do
    json = filepath |> File.read!() |> Jason.decode!() |> Map.get("monitors")

    json
    |> Enum.map(fn attrs ->
      attrs =
        Map.merge(attrs, %{
          "account_id" => account_id,
          "inserted_at" => DateTime.utc_now(),
          "updated_at" => DateTime.utc_now()
        })

      case create_monitor(attrs) do
        {:ok, monitor} ->
          monitor

        error ->
          Logger.error(inspect(error))
          nil
      end
    end)
    |> Enum.filter(& &1)
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
      from(i in Incident, where: [monitor_id: ^monitor_id]),
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
    # TODO: too short interval
    hour_ago = DateTime.add(DateTime.utc_now(), -1, :minute)

    series =
      from(
        f in fragment(
          "select generate_series('today 17:00'::timestamp, (?)::timestamp, interval '1 minutes') grid_time",
          ^hour_ago
        ),
        as: :grid_time
      )
      |> join(
        :left_lateral,
        [],
        subquery(
          Check
          |> where([c], c.inserted_at >= parent_as(:grid_time).grid_time)
          |> where([c], c.inserted_at < parent_as(:grid_time).grid_time + fragment("interval '10 minutes'"))
          |> where([c], c.monitor_id == ^monitor_id)
          |> order_by(desc: :id)
          |> limit(1)
        ),
        on: true
      )
      |> select([f, a], %{grid_time: f.grid_time, inserted_at: a.inserted_at, result: a.result})
      |> Repo.all()

    %{
      result_series: Enum.map(series, &if(&1.result == :success, do: 1, else: 0)),
      time_series: Enum.map(series, & &1.grid_time)
    }
  end

  def list_checks_for_response_times(%Monitor{id: monitor_id}) do
    hour_ago = DateTime.add(DateTime.utc_now(), -1, :minute)

    series =
      from(
        f in fragment(
          "select generate_series('today 00:00'::timestamp, (?)::timestamp, interval '10 minutes') grid_time",
          ^hour_ago
        ),
        as: :grid_time
      )
      |> join(
        :left_lateral,
        [],
        subquery(
          Check
          |> where([c], c.inserted_at >= parent_as(:grid_time).grid_time)
          |> where([c], c.inserted_at < parent_as(:grid_time).grid_time + fragment("interval '10 minutes'"))
          |> where([c], c.monitor_id == ^monitor_id)
          |> order_by(desc: :id)
          |> limit(1)
        ),
        on: true
      )
      |> where([f, a], not is_nil(f.grid_time) and not is_nil(a.duration))
      |> select([f, a], %{
        grid_time: fragment("to_char(?, 'YYYY-MM-DD HH24:MI:SS')", f.grid_time),
        inserted_at: a.inserted_at,
        duration: a.duration
      })
      |> Repo.all()

    %{duration_series: Enum.map(series, & &1.duration), time_series: Enum.map(series, & &1.grid_time)}
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

  def last_five_incidents(%Monitor{id: monitor_id}) do
    Repo.all(
      from(c in Incident,
        where: [monitor_id: ^monitor_id],
        order_by: [desc: :id],
        limit: 5
      )
    )
  end

  def this_month_incidents_count(%Monitor{id: monitor_id}) do
    Repo.aggregate(
      from(i in Incident,
        where: [monitor_id: ^monitor_id],
        where: fragment("DATE_TRUNC('month', inserted_at) = DATE_TRUNC('month', LOCALTIMESTAMP)"),
        select: i.id
      ),
      :count,
      :id
    )
  end

  def last_checked_at(%Monitor{id: monitor_id}) do
    Repo.one(
      from(c in Check,
        where: [monitor_id: ^monitor_id],
        order_by: [desc: :id],
        limit: 1,
        select: c.inserted_at
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

  def get_incident(id) do
    Repo.get(Incident, id)
  end
end
