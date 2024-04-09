defmodule Sentinel.Monitors.UseCases.RunCheck do
  @moduledoc false
  alias Sentinel.Events
  alias Sentinel.Monitors.Check
  alias Sentinel.Monitors.Incident
  alias Sentinel.Monitors.Monitor
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

  defp create_check!(monitor, %Finch.Response{status: status} = finch_response, duration) do
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

      monitor
      |> Repo.preload([:last_check, :last_incident])
      |> process_incident(check)
    end)
  end

  defp process_incident(
         %Monitor{last_check: nil} = monitor,
         %Check{id: check_id, inserted_at: inserted_at, result: :failure} = check
       ) do
    incident = start_incident(monitor, check)

    Events.create_event(:monitor_down, monitor, %{downed_at: inserted_at})
    update_monitor(monitor, %{last_check_id: check_id, last_incident_id: incident.id})
  end

  defp process_incident(%Monitor{last_check: nil} = monitor, %Check{id: check_id, result: :success}) do
    update_monitor(monitor, %{last_check_id: check_id})
  end

  defp process_incident(%Monitor{last_check: %Check{result: :success}} = monitor, %Check{
         id: check_id,
         result: :success
       }) do
    update_monitor(monitor, %{last_check_id: check_id})
  end

  defp process_incident(
         %Monitor{last_check: %Check{result: :success}} = monitor,
         %Check{id: check_id, inserted_at: inserted_at, result: :failure} = check
       ) do
    incident = start_incident(monitor, check)

    Events.create_event(:monitor_down, monitor, %{downed_at: inserted_at})
    update_monitor(monitor, %{last_check_id: check_id, last_incident_id: incident.id})
  end

  defp process_incident(%Monitor{last_check: %Check{result: :failure}} = monitor, %Check{
         id: check_id,
         result: :failure
       }) do
    update_monitor(monitor, %{last_check_id: check_id})
  end

  defp process_incident(%Monitor{last_check: %Check{result: :failure}} = monitor, %Check{
         id: check_id,
         inserted_at: inserted_at,
         result: :success
       }) do
    resolve_incident(monitor, check_id)

    # Events.create_event(:monitor_up, monitor, %{upped_at: inserted_at, check_id: check_id})
    update_monitor(monitor, %{last_check_id: check_id})
  end

  defp start_incident(monitor, check) do
    %Incident{}
    |> Incident.start_changeset(%{
      monitor_id: monitor.id,
      start_check_id: check.id,
      started_at: DateTime.utc_now(),
      http_code: check.status_code,
      status: :started
    })
    |> Repo.insert!()
  end

  defp resolve_incident(monitor, check_id) do
    monitor.last_incident
    |> Incident.end_changeset(%{
      ended_at: DateTime.utc_now(),
      end_check_id: check_id
    })
    |> Repo.update!()
  end

  defp update_monitor(monitor, attrs) do
    monitor
    |> Monitor.changeset(attrs)
    |> Sentinel.Repo.update!()
  end
end
