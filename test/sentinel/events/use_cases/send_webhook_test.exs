defmodule Sentinel.Events.UseCases.SendWebhookTest do
  use Sentinel.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  import Sentinel.AccountsFixtures
  import Sentinel.ChecksFixtures
  import Sentinel.EventsFixtures
  import Sentinel.IntegrationsFixtures

  alias Sentinel.Events.UseCases.SendWebhook

  setup do
    user = user_fixture()
    monitor = monitor_fixture(%{account_id: user.account_id})
    event = event_fixture(%{type: :monitor_down, resource: monitor})
    webhook = webhook_fixture(%{account_id: user.account_id})

    acceptor =
      acceptor_fixture(%{
        recipient: %{id: webhook.id, type: to_string(webhook.__struct__)},
        event_id: event.id,
        recipient_type: "webhook"
      })

    [event: event, user: user, resource: monitor, acceptor: acceptor, webhook: webhook]
  end

  describe "call/1" do
    test "send webhook", %{event: event, resource: resource, acceptor: acceptor, webhook: webhook} do
      use_cassette "send_webhook" do
        {:ok, :sent} =
          SendWebhook.call(%{
            acceptor: acceptor,
            recipient: webhook,
            resource: resource,
            event_type: String.to_existing_atom(event.type.type)
          })

        Process.sleep(100)
      end
    end
  end
end
