defmodule Sentinel.Events do
  @moduledoc false
  alias Sentinel.Events.Event
  alias Ubr.Repo

  def create_event!(payload) do
    %Event{id: id} =
      Event.create!(payload)

    %{id: id}
    |> CollectEvent.new()
    |> Oban.insert!()
  end

  def get_event(id) do
    Repo.get(Event, id)
  end
end
