defmodule Sentinel.Events.UseCases.NotifyAcceptorTest do
  use Sentinel.DataCase, async: true

  import Sentinel.ChecksFixtures
  import Sentinel.EventsFixtures

  setup do
    monitor = monitor_fixture()
    event = event_fixture(type: :monitor_down, resource: monitor)
  end

  describe "call/1" do
    test "notify acceptor for monitor down event" do
    end
  end
end
