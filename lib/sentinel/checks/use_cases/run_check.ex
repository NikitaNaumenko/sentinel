defmodule Sentinel.Checks.UseCases.RunCheck do
  @moduledoc false
  alias Sentinel.Checks.Check
  alias Sentinel.Events

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
      |> Events.create_event!()
    end)
  end
end
