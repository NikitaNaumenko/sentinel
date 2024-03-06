defmodule Sentinel.Events.Workers.NotifyAcceptor do
  @moduledoc false
  use Oban.Worker, queue: :notifications

  alias Sentinel.Events.UseCases.NotifyAcceptor

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    NotifyAcceptor.call(id)
  end

  def perform(%Oban.Job{args: %{"ids" => ids}}) do
    Enum.map(ids, fn id -> NotifyAcceptor.call(id) end)
  end
end
