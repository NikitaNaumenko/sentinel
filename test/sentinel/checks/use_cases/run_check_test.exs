defmodule Sentinel.Checks.UseCases.RunCheckTest do
  use Sentinel.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  import Sentinel.AccountsFixtures
  import Sentinel.ChecksFixtures

  alias Sentinel.Checks
  alias Sentinel.Checks.Check
  alias Sentinel.Checks.Incident
  alias Sentinel.Checks.Monitor
  alias Sentinel.Checks.UseCases.RunCheck

  setup do
    account = account_fixture(%{name: "account"})
    [account_id: account.id]
  end

  describe "when last check nil" do
    setup %{account_id: account_id} do
      monitor = monitor_fixture(%{account_id: account_id, notification_rule: %{via_email: true}})
      [monitor: monitor]
    end

    test "when next check success", %{monitor: monitor} do
      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :success} = Checks.get_check(monitor.last_check_id)
      end
    end

    test "when next check failure", %{monitor: monitor} do
      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :failure} = Checks.get_check(monitor.last_check_id)
        assert %Incident{} = Checks.get_incident(monitor.last_incident_id)
      end
    end
  end

  describe "when last check success" do
  end

  describe "when last check failure" do
  end
end
