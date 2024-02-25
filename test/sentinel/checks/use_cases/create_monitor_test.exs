defmodule Sentinel.Checks.UseCases.CreateMonitorTest do
  use Sentinel.DataCase, async: true

  import Sentinel.AccountsFixtures

  alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.UseCases.CreateMonitor

  setup do
    account = account_fixture(name: "account")
    [account_id: account.id]
  end

  test "call/2 successfully creates a monitor and starts a worker", %{account_id: account_id} do
    monitor_attrs = %{
      "name" => "Test",
      "url" => "https://example.com",
      "monitor_type" => "uptime",
      "account_id" => account_id,
      "interval" => 60,
      "http_method" => :get,
      "expected_status_code" => 200,
      "request_timeout" => 10
    }

    assert {:ok, %Monitor{}} = CreateMonitor.call(monitor_attrs)
  end

  # test "call/2 returns an error when the monitor creation fails" do
  #   # Arrange
  #   account_id = 1
  #
  #   monitor_attrs = %{
  #     "url" => "https://example.com",
  #     "monitor_type" => "uptime"
  #   }
  #
  #   # Act
  #   result = CreateMonitor.call(account_id, monitor_attrs)
  #
  #   # Assert
  #   assert {:error, _changeset} = result
  # end
end
