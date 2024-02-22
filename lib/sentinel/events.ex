defmodule Sentinel.Events do
  @moduledoc false
  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Event
  alias Sentinel.Events.Workers.CollectEventAcceptors
  alias Sentinel.Repo

  def create_event(type, resource, payload \\ %{}) do
    Sentinel.Repo.transaction(fn ->
      event = create_event!(type, resource, payload)

      %{id: event.id}
      |> CollectEventAcceptors.new()
      |> Oban.insert!()

      event
    end)
  end

  @spec create_event(atom(), map(), map()) :: Event.t()
  def create_event!(type, resource, payload \\ %{}) do
    %Event{}
    |> Event.changeset(%{
      type: type,
      resource_id: resource.id,
      resource_type: to_string(resource.__struct__),
      payload: payload
    })
    |> Repo.insert!()
  end

  def get_event(id) do
    Repo.get(Event, id)
  end

  def get_acceptor(id) do
    Repo.get(Acceptor, id)
  end
end
