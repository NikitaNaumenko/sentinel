defmodule Sentinel.Checks.Workers.StartApplicationWorker do
  @moduledoc """
      Worker that start all monitors asynchoronously during startup application.
  """
  use Oban.Worker, queue: :monitors

  alias Sentinel.Checks
  alias Sentinel.Checks.Workers.StartMonitor

  @impl Oban.Worker
  def perform(_args) do
    # TODO: Rewrite query
    for monitor <- Checks.list_monitors() do
      %{id: monitor.id}
      |> StartMonitor.new()
      |> Oban.insert()
    end

    :ok
  end
end
