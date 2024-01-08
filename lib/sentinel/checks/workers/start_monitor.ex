defmodule Sentinel.Checks.Workers.StartMonitor do
  @moduledoc """
    Worker that start a monitor asynchoronously.
  """
  use Oban.Worker, queue: :monitors

  alias Sentinel.Checks
  # alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.MonitorWorker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    monitor = Checks.get_monitor!(id)
    # TODO: Maybe check start state
    MonitorWorker.start_link(monitor)
  end
end
