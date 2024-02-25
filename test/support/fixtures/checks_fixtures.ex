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
      %{
        name: "Monitor #{System.unique_integer()}",
        url: "http://example.com",
        interval: 60,
        http_method: :get,
        expected_status_code: 200,
        request_timeout: 10,
        notification_rule: %{via_email: true, via_webhook: true}
      }
      |> Map.merge(attrs)
      |> struct(Sentinel.Checks.Monitor)
      |> Sentinel.Repo.insert()

    monitor
  end
end
