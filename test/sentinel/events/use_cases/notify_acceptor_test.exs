defmodule Sentinel.Events.UseCases.NotifyAcceptorTest do
  use Sentinel.DataCase, async: true

  import Sentinel.AccountsFixtures
  import Sentinel.ChecksFixtures
  import Sentinel.EventsFixtures

  alias Sentinel.Events.UseCases.NotifyAcceptor

  setup do
    user = user_fixture()
    monitor = monitor_fixture(%{account_id: user.account_id})
    event = event_fixture(%{type: :monitor_down, resource: monitor})
    acceptor = acceptor_fixture(recipient_id: user.id, event_id: event.id)
    [acceptor: acceptor]
  end

  describe "call/1" do
    test "notify acceptor for monitor down event", %{acceptor: acceptor} do
      assert [:email_sent, :webhook_sent] = NotifyAcceptor.call(acceptor)
    end
  end
end
