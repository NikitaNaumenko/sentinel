defmodule Sentinel.Checks.UseCases.RunCheck do
  @moduledoc false
  alias Sentinel.Checks.Check
  alias Sentinel.Checks.Incident
  alias Sentinel.Checks.Monitor
  alias Sentinel.Events
  alias Sentinel.Repo

  def call(monitor) do
    # TODO: Should be calculated by telemetry
    start_time = System.monotonic_time(:millisecond)
    result = monitor.http_method |> Finch.build(monitor.url) |> Finch.request(Sentinel.Finch)
    end_time = System.monotonic_time(:millisecond)

    case result do
      {:ok, response} ->
        create_check!(monitor, response, end_time - start_time)

      error ->
        error
    end
  end

  def create_check!(monitor, %Finch.Response{status: status} = finch_response, duration) do
    Sentinel.Repo.transaction(fn ->
      check =
        %{
          raw_response: finch_response,
          result: Check.define_result(monitor.expected_status_code, status),
          reason: nil,
          duration: duration,
          status_code: status,
          monitor_id: monitor.id
        }
        |> Check.changeset()
        |> Sentinel.Repo.insert!()

      monitor = Repo.preload(monitor, [:last_check])

      process_incident(monitor, check)
    end)
  end

  defp process_incident(
         %Monitor{last_check: nil} = monitor,
         %Check{id: check_id, inserted_at: inserted_at, result: :failure} = check
       ) do
    incident = start_incident(monitor, check_id)

    monitor
    |> Monitor.changeset(%{last_check_id: check_id, last_not_resolved_incident_id: incident.id})
    |> Sentinel.Repo.update!()

    Events.create_event(:monitor_down, monitor, %{downed_at: inserted_at})
  end

  defp process_incident(%Monitor{last_check: nil} = monitor, %Check{id: check_id, result: :success}) do
    monitor
    |> Monitor.changeset(%{last_check_id: check_id})
    |> Sentinel.Repo.update!()
  end

  defp process_incident(%Monitor{last_check: %Check{result: :success}} = monitor, %Check{
         id: check_id,
         result: :success
       }) do
    monitor
    |> Monitor.changeset(%{last_check_id: check_id})
    |> Sentinel.Repo.update!()
  end

  defp process_incident(%Monitor{last_check: %Check{result: :success}} = monitor, %Check{
         id: check_id,
         inserted_at: inserted_at,
         result: :falure
       }) do
    incident = start_incident(monitor, check_id)

    monitor
    |> Monitor.changeset(%{last_check_id: check_id, last_incident_id: incident.id})
    |> Sentinel.Repo.update!()

    Events.create_event(:monitor_down, monitor, %{downed_at: inserted_at})
  end

  defp process_incident(%Monitor{last_check: %Check{result: :failure}} = monitor, %Check{
         id: check_id,
         result: :falure
       }) do
    monitor
    |> Monitor.changeset(%{last_check_id: check_id})
    |> Sentinel.Repo.update!()
  end

  defp process_incident(%Monitor{last_check: %Check{result: :failure}} = monitor, %Check{
         id: check_id,
         inserted_at: inserted_at,
         result: :success
       }) do
    resolve_incident(monitor, check_id)

    monitor
    |> Monitor.changeset(%{last_check_id: check_id})
    |> Sentinel.Repo.update!()

    Events.create_event(:monitor_up, monitor, %{upped_at: inserted_at, check_id: check_id})
  end

  defp start_incident(monitor, check) do
    %Incident{}
    |> Incident.changeset(%{
      monitor_id: monitor.id,
      start_check_id: check.id,
      started_at: DateTime.utc_now(),
      http_code: check.code,
      status: :started
    })
    |> Repo.insert!()
  end

  defp resolve_incident(monitor, check_id) do
    monitor.last_not_resolved_incident
    |> Incident.changeset(%{
      ended_at: DateTime.utc_now(),
      end_check_id: check_id
    })
    |> Repo.update!()
  end
end
