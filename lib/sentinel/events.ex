defmodule Sentinel.Events do
  @moduledoc false
  alias Sentinel.Events.Event
  alias Sentinel.Repo

  def create_event!(_payload) do
    # %Event{id: id} =
    #   Event.create!(payload)
    #
    # %{id: id}
    # |> CollectEvent.new()
    # |> Oban.insert!()
  end

  def get_event(id) do
    Repo.get(Event, id)
  end

  def get_acceptor(_id) do
  end
end
