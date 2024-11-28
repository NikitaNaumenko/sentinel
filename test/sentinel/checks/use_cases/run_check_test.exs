defmodule Sentinel.Monitors.UseCases.RunCheckTest do
  use Sentinel.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  import Sentinel.AccountsFixtures
  import Sentinel.EscalationsFixtures
  import Sentinel.MonitorsFixtures


  alias Sentinel.Monitors
  alias Sentinel.Monitors.Check
  alias Sentinel.Monitors.Incident
  alias Sentinel.Monitors.UseCases.RunCheck

  setup do
    escalation_alert_attrs = escalation_alert_attrs(%{alert_type: :email})
    escalation_step_attrs = escalation_step_attrs(%{escalation_alerts: [escalation_alert_attrs]})
    escalation_policy = escalation_policy_fixture(%{escalation_steps: [escalation_step_attrs]})
    account = account_fixture(%{name: "account"})

    monitor = monitor_fixture(%{account_id: account.id, escalation_policy_id: escalation_policy.id})
    [account_id: account.id, monitor: monitor]
  end

  describe "when last check nil" do
    test "next check success", %{monitor: monitor} do
      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor.id)
        assert %Check{result: :success} = Monitors.get_check(monitor.last_check_id)
        assert is_nil(monitor.last_incident_id)
      end
    end

    test "next check failure create incident", %{monitor: monitor} do
      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor.id)
        assert %Check{result: :failure} = Monitors.get_check(monitor.last_check_id)
        assert %Incident{status: :started} = Monitors.get_incident(monitor.last_incident_id)
      end
    end
  end

  describe "when last check success" do
    setup %{monitor: monitor} do
      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor.id)
        [monitor_id: monitor.id]
      end
    end

    test "next check success", %{monitor_id: monitor_id} do
      use_cassette "check_success" do
        {:ok, monitor} = RunCheck.call(monitor_id)
        assert %Check{result: :success} = Monitors.get_check(monitor.last_check_id)
        assert is_nil(monitor.last_incident_id)
      end
    end

    test "next check failure create incident", %{monitor_id: monitor_id} do
      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor_id)
        assert %Check{result: :failure} = Monitors.get_check(monitor.last_check_id)
        assert %Incident{status: :started} = Monitors.get_incident(monitor.last_incident_id)
      end
    end
  end

  describe "when last check failure" do
    setup %{monitor: monitor} do
      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor.id)
        [monitor_id: monitor.id]
      end
    end

    test "next check success resolve incident", %{monitor_id: monitor_id} do
      monitor = Monitors.get_monitor!(monitor_id)

      use_cassette "check_success" do
        assert %Check{result: :failure} = Monitors.get_check(monitor.last_check_id)
        {:ok, monitor} = RunCheck.call(monitor_id)
        assert %Check{result: :success} = Monitors.get_check(monitor.last_check_id)
        assert %Incident{status: :resolved} = Monitors.get_incident(monitor.last_incident_id)
      end
    end

    test "next check failure create incident", %{monitor_id: monitor_id} do
      monitor = Monitors.get_monitor!(monitor_id)
      last_incident_id = monitor.last_incident_id

      use_cassette "check_failure" do
        {:ok, monitor} = RunCheck.call(monitor_id)
        assert %Check{result: :failure} = Monitors.get_check(monitor.last_check_id)

        assert %Incident{status: :started, id: ^last_incident_id} =
                 Monitors.get_incident(monitor.last_incident_id)
      end
    end
  end
end
