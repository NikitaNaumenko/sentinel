defmodule Sentinel.Checks.MonitorWorker do
  @moduledoc false
  use GenServer

  alias Sentinel.Checks
  alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.MonitorSupervisor

  def start_link(monitor) do
    MonitorSupervisor.start_child(monitor)
  end

  @impl GenServer
  def init(%{monitor: monitor}) do
    {:ok, %{monitor: monitor}, {:continue, :setup_monitor}}
  end

  @impl GenServer
  def handle_continue(:setup_monitor, %{monitor: monitor} = state) do
    interval = monitor.interval * 1_000
    :timer.send_interval(interval, :run_check)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:run_check, %{monitor: %Monitor{expected_status_code: _status} = monitor} = state) do
    start_time = System.monotonic_time(:millisecond)
    result = monitor.http_method |> Finch.build(monitor.url) |> Finch.request(Sentinel.Finch)
    end_time = System.monotonic_time(:millisecond)

    case result do
      {:ok, response} ->
        check = Monitor.create_check!(monitor, response, end_time - start_time)
        Checks.broadcast("monitors-#{monitor.account_id}", %Monitor{monitor | last_check: check.result})

      _ ->
        IO.inspect(:error)
    end

    {:noreply, state}
  end
end
