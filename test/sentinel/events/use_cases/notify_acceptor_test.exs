defmodule Sentinel.Events.UseCases.NotifyAcceptorTest do
  use Sentinel.DataCase, async: true

  import Sentinel.AccountsFixtures
  import Sentinel.ChecksFixtures
  import Sentinel.EventsFixtures
  import Sentinel.IntegrationsFixtures

  alias Sentinel.Events.UseCases.NotifyAcceptor

  setup do
    user = user_fixture()
    monitor = monitor_fixture(%{account_id: user.account_id})
    event = event_fixture(%{type: :monitor_down, resource: monitor})

    [event: event, user: user]
  end

  describe "call/1" do
    test "notify email acceptor for monitor down event", %{event: event, user: user} do
      acceptor =
        acceptor_fixture(%{recipient: %{id: user.id, type: to_string(user.__struct__)}, event_id: event.id})

      assert [:ok] = NotifyAcceptor.call(acceptor)
    end

    test "notify webhook acceptor for monitor down event", %{event: event, user: user} do
      webhook = webhook_fixture(%{account_id: user.account_id})

      acceptor =
        acceptor_fixture(%{
          recipient: %{id: webhook.id, type: to_string(webhook.__struct__)},
          event_id: event.id
        })

      assert [:ok] = NotifyAcceptor.call(acceptor)
    end
  end
end
