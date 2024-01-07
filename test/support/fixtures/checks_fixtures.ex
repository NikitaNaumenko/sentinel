defmodule Sentinel.ChecksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Checks` context.
  """

  @doc """
  Generate a monitor.
  """
  def monitor_fixture(attrs \\ %{}) do
    {:ok, monitor} =
      attrs
      |> Enum.into(%{})
      |> Sentinel.Checks.create_monitor()

    monitor
  end
end
