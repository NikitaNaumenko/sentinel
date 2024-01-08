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
  def handle_info(:run_check, %{monitor: %Monitor{expected_status_code: status} = monitor} = state) do
    result = monitor.http_method |> Finch.build(monitor.url) |> Finch.request(Sentinel.Finch)

    # case result do
    #   {:ok, %Finch.Response{status: ^status} = response} ->
    #     # IO.inspect(response)
    #     # check = Monitor.create_check!(monitor, response)
    #     # Checks.broadcast("monitors-#{monitor.account_id}", %Monitor{monitor | last_check: check.result})
    #
    #   _ ->
    #     IO.inspect(:error)
    # end
    #
    {:noreply, state}
  end
end
