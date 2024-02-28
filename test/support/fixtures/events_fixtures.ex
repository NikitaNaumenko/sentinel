defmodule Sentinel.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Events` context.
  """

  alias Sentinel.Events
  alias Sentinel.Events.Acceptor

  @doc """
  Generate an event.
  """
  def event_fixture(%{type: type, resource: resource}) do
    Events.create_event!(type, resource, %{})
  end

  def acceptor_fixture(attrs \\ %{}) do
    %Acceptor{}
    |> Acceptor.changeset(attrs)
    |> Sentinel.Repo.insert!()
  end
end
