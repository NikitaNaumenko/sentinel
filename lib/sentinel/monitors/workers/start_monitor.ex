defmodule Sentinel.Monitors.Workers.StartMonitor do
  @moduledoc """
    Worker that start a monitor asynchoronously.
  """
  use Oban.Worker, queue: :monitors

  alias Sentinel.Monitors
  # alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorWorker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    monitor = Monitors.get_monitor!(id)
    # TODO: Maybe check start state
    MonitorWorker.start_link(monitor)
  end
end
