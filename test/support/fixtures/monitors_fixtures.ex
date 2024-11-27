defmodule Sentinel.MonitorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Monitors` context.
  """

  alias Sentinel.Monitors.Monitor
  alias Sentinel.Repo

  @doc """
  Generate a monitor.
  """
  def monitor_fixture(attrs \\ %{}) do
    attrs =
      Map.merge(
        %{
          name: "Monitor #{System.unique_integer()}",
          url: "http://example.com",
          interval: 60,
          http_method: :get,
          expected_status_code: 200,
          request_timeout: 10,
          notification_rule: %{via_email: true, via_webhook: true}
        },
        attrs
      )

    {:ok, monitor} =
      %Monitor{}
      |> Monitor.changeset(attrs)
      |> Repo.insert()

    monitor
  end
end
