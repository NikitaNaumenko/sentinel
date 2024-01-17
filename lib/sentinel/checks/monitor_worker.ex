defmodule Sentinel.Checks.MonitorWorker do
  @moduledoc false
  use GenServer

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
  def handle_info(:run_check, %{monitor: monitor} = state) do
    RunCheck.call(monitor)
    {:noreply, state}
  end
end
