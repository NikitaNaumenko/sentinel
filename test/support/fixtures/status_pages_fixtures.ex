defmodule Sentinel.StatusPagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.StatusPages` context.
  """

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Map.new()
      |> Sentinel.StatusPages.create_page()

    page
  end
end
