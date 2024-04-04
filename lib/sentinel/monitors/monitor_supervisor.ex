defmodule Sentinel.Monitors.MonitorSupervisor do
  @moduledoc false
  use DynamicSupervisor

  alias Sentinel.Monitors.MonitorWorker
  alias Sentinel.Monitors.Workers.StartApplicationWorker

  @impl DynamicSupervisor
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(monitor) do
    spec = %{
      id: GenServer,
      start:
        {GenServer, :start_link,
         [
           MonitorWorker,
           %{monitor: monitor},
           [name: worker_name(monitor)]
         ]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def start_link(init_arg) do
    # Prepare monitors while application is starting
    #
    return = DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    Oban.insert(StartApplicationWorker.new(%{}))
    return
  end

  defp worker_name(monitor) do
    {:via, Registry, {Sentinel.Monitors.Registry, "monitor-#{monitor.account_id}-#{monitor.id}"}}
  end
end
