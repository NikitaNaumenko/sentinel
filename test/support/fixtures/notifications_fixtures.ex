defmodule Sentinel.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Map.new()
      |> Sentinel.Notifications.create_notification()

    notification
  end
end
