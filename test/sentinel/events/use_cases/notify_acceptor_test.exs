defmodule Sentinel.Events.UseCases.NotifyAcceptorTest do
  use Sentinel.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  import Sentinel.AccountsFixtures
  import Sentinel.EventsFixtures
  import Sentinel.IntegrationsFixtures
  import Sentinel.MonitorsFixtures
  import Swoosh.TestAssertions

  alias Sentinel.Events.UseCases.NotifyAcceptor

  setup do
    user = user_fixture()
    monitor = monitor_fixture(%{account_id: user.account_id})
    event = event_fixture(%{type: :monitor_down, resource: monitor})

    [event: event, user: user, monitor: monitor]
  end

  describe "call/1" do
    test "notify email acceptor for monitor down event", %{event: event, user: user, monitor: monitor} do
      acceptor =
        acceptor_fixture(%{
          recipient: %{id: user.id, type: to_string(user.__struct__)},
          event_id: event.id,
          recipient_type: "email"
        })

      assert {:ok, :sent} = NotifyAcceptor.call(acceptor.id)

      Process.sleep(100)
      email = Sentinel.Events.Notifications.Email.monitor_down(%{monitor: monitor, user: user})
      assert_email_sent(email)
    end

    test "notify webhook acceptor for monitor down event", %{event: event, user: user} do
      use_cassette "send_webhook" do
        webhook = webhook_fixture(%{account_id: user.account_id})

        acceptor =
          acceptor_fixture(%{
            recipient: %{id: webhook.id, type: to_string(webhook.__struct__)},
            event_id: event.id,
            recipient_type: "webhook"
          })

        assert {:ok, :sent} = NotifyAcceptor.call(acceptor.id)
        Process.sleep(100)
      end
    end
  end
end
