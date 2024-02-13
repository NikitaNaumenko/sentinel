defmodule Sentinel.Events.Workers.NotifyAcceptor do
  @moduledoc false
  use Oban.Worker, queue: :notifications

  import Ecto.Query

  alias Sentinel.Checks
  alias Sentinel.Events
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  alias Sentinel.Events.UseCases.NotifyAcceptor
  alias Sentinel.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    acceptor = Events.get_acceptor(id)

    NotifyAcceptor.run(acceptor)
  end
end
