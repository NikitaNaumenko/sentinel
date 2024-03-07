defmodule Sentinel.Checks.UseCases.CreateMonitorTest do
  use Sentinel.DataCase, async: true

  import Sentinel.AccountsFixtures

  alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.MonitorWorker
  alias Sentinel.Checks.UseCases.CreateMonitor

  setup do
    account = account_fixture(%{name: "account"})
    [account_id: account.id]
  end

  test "call/2 successfully creates a monitor and starts a worker", %{account_id: account_id} do
    monitor_attrs = %{
      "name" => "Test",
      "url" => "https://example.com",
      "account_id" => account_id,
      "interval" => 60,
      "http_method" => :get,
      "expected_status_code" => 200,
      "request_timeout" => 10
    }

    assert {:ok, %Monitor{} = monitor} = CreateMonitor.call(monitor_attrs)
    assert {:error, {:already_started, _}} = MonitorWorker.start_link(monitor)
  end

  test "call/2 returns an error when the monitor creation fails", %{account_id: account_id} do
    monitor_attrs = %{
      "account_id" => account_id,
      "url" => "https://example.com"
    }

    {:error, %Ecto.Changeset{}} = CreateMonitor.call(monitor_attrs)
  end
end
