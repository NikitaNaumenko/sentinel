defmodule Sentinel.ChecksTest do
  use Sentinel.DataCase

  alias Sentinel.Checks

  describe "monitors" do
    alias Sentinel.Checks.Monitor

    import Sentinel.ChecksFixtures

    @invalid_attrs %{}

    test "list_monitors/0 returns all monitors" do
      monitor = monitor_fixture()
      assert Checks.list_monitors() == [monitor]
    end

    test "get_monitor!/1 returns the monitor with given id" do
      monitor = monitor_fixture()
      assert Checks.get_monitor!(monitor.id) == monitor
    end

    test "create_monitor/1 with valid data creates a monitor" do
      valid_attrs = %{}

      assert {:ok, %Monitor{} = monitor} = Checks.create_monitor(valid_attrs)
    end

    test "create_monitor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checks.create_monitor(@invalid_attrs)
    end

    test "update_monitor/2 with valid data updates the monitor" do
      monitor = monitor_fixture()
      update_attrs = %{}

      assert {:ok, %Monitor{} = monitor} = Checks.update_monitor(monitor, update_attrs)
    end

    test "update_monitor/2 with invalid data returns error changeset" do
      monitor = monitor_fixture()
      assert {:error, %Ecto.Changeset{}} = Checks.update_monitor(monitor, @invalid_attrs)
      assert monitor == Checks.get_monitor!(monitor.id)
    end

    test "delete_monitor/1 deletes the monitor" do
      monitor = monitor_fixture()
      assert {:ok, %Monitor{}} = Checks.delete_monitor(monitor)
      assert_raise Ecto.NoResultsError, fn -> Checks.get_monitor!(monitor.id) end
    end

    test "change_monitor/1 returns a monitor changeset" do
      monitor = monitor_fixture()
      assert %Ecto.Changeset{} = Checks.change_monitor(monitor)
    end
  end
end
