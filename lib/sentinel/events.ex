defmodule Sentinel.Events do
  @moduledoc false
  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Event
  alias Sentinel.Events.Workers.CollectEventAcceptors
  alias Sentinel.Repo

  def create_event!(type, resource, payload \\ %{}) do
    %Event{id: id} =
      Event.create!(%{
        type: type,
        resource_id: resource.id,
        resource_type: to_string(resource.__struct__),
        payload: payload
        # creator_id: get_in(resource, Access.key(:creator_id, nil))
      })

    %{id: id}
    |> CollectEventAcceptors.new()
    |> Oban.insert!()
  end

  def get_event(id) do
    Repo.get(Event, id)
  end

  def get_acceptor(id) do
    Repo.get(Acceptor, id)
  end
end
