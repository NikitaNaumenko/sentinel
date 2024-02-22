defmodule Sentinel.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Events` context.
  """

  alias Sentinel.Events

  @doc """
  Generate an event.
  """
  def event_fixture(attrs \\ %{}) do
    attrs
    |> Map.new()
    |> Events.create_event!()
  end
end
