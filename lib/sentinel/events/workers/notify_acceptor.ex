defmodule Sentinel.Events.Workers.NotifyAcceptor do
  @moduledoc false
  use Oban.Worker, queue: :notifications

  alias Sentinel.Events
  alias Sentinel.Events.UseCases.NotifyAcceptor

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    acceptor = Events.get_acceptor(id)

    NotifyAcceptor.call(acceptor)
  end
end
