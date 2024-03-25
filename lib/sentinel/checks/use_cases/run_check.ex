defmodule Sentinel.Checks.UseCases.RunCheck do
  @moduledoc false
  alias Sentinel.Checks.Check
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
      |> case do
        %Check{result: :failure, inserted_at: inserted_at, id: check_id} ->
          monitor
          |> Monitor.changeset(%{last_check_id: check_id})
          |> Sentinel.Repo.update!()

          Events.create_event(:monitor_down, monitor, %{downed_at: inserted_at})

        # TODO: тут будет логика когда монитор поднялся
        _ ->
          :ok
      end
    end)
  end

  defp start_incident(monitor, check) do
    %{
      monitor_id: monitor.id,
      start_check_id: check.id,
      started_at: DateTime.utc_now(),
      http_code: check.code,
      status: :started
    }
    |> Incident.changeset()
    |> Repo.insert!()
  end
end
