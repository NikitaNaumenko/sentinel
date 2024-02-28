defmodule Sentinel.ChecksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Checks` context.
  """

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
      %Sentinel.Checks.Monitor{}
      |> Sentinel.Checks.Monitor.changeset(attrs)
      |> Sentinel.Repo.insert()

    monitor
  end
end
