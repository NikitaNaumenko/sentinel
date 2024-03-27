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

    monitor = monitor_fixture(%{account_id: account.id, notification_rule: %{via_email: true}})
    [account_id: account.id, monitor: monitor]
  end

  describe "when last check nil" do
    test "next check success", %{monitor: monitor} do
      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :success} = Checks.get_check(monitor.last_check_id)
        assert is_nil(monitor.last_incident_id)
      end
    end

    test "next check failure create incident", %{monitor: monitor} do
      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :failure} = Checks.get_check(monitor.last_check_id)
        assert %Incident{status: :started} = Checks.get_incident(monitor.last_incident_id)
      end
    end
  end

  describe "when last check success" do
    setup %{monitor: monitor} do
      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor)
        [monitor_id: monitor.id]
      end
    end

    test "next check success", %{monitor_id: monitor_id} do
      monitor = Checks.get_monitor!(monitor_id)

      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :success} = Checks.get_check(monitor.last_check_id)
        assert is_nil(monitor.last_incident_id)
      end
    end

    test "next check failure create incident", %{monitor_id: monitor_id} do
      monitor = Checks.get_monitor!(monitor_id)

      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :failure} = Checks.get_check(monitor.last_check_id)
        assert %Incident{status: :started} = Checks.get_incident(monitor.last_incident_id)
      end
    end
  end

  describe "when last check failure" do
    setup %{monitor: monitor} do
      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor)
        [monitor_id: monitor.id]
      end
    end

    test "next check success resolve incident", %{monitor_id: monitor_id} do
      monitor = Checks.get_monitor!(monitor_id)

      use_cassette "check_success" do
        assert %Check{result: :failure} = Checks.get_check(monitor.last_check_id)
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :success} = Checks.get_check(monitor.last_check_id)
        assert %Incident{status: :resolved} = Checks.get_incident(monitor.last_incident_id)
      end
    end

    test "next check failure create incident", %{monitor_id: monitor_id} do
      monitor = Checks.get_monitor!(monitor_id)
      last_incident_id = monitor.last_incident_id

      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor)
        assert %Check{result: :failure} = Checks.get_check(monitor.last_check_id)

        assert %Incident{status: :started, id: ^last_incident_id} =
                 Checks.get_incident(monitor.last_incident_id)
      end
    end
  end
end
