defmodule Sentinel.Events.UseCases.SendTelegramTest do
  use Sentinel.DataCase
  use Repatch.ExUnit

  import Sentinel.AccountsFixtures
  import Sentinel.EventsFixtures
  import Sentinel.IntegrationsFixtures
  import Sentinel.MonitorsFixtures

  alias Sentinel.Events.UseCases.SendTelegram

  setup do
    account = account_fixture()
    telegram = telegram_fixture(%{account_id: account.id})
    monitor = monitor_fixture(%{account_id: account.id})
    event = event_fixture(%{type: :monitor_down, resource: monitor})

    acceptor =
      acceptor_fixture(%{
        recipient: %{id: telegram.id, type: to_string(telegram.__struct__)},
        event_id: event.id,
        recipient_type: "telegram"
      })

    [event: event, telegram: telegram, resource: monitor, acceptor: acceptor]
  end

  describe "call/1" do
    test "send telegram request", %{telegram: telegram, event: event, resource: resource, acceptor: acceptor} do
      {:ok, :sent} =
        SendTelegram.call(%{
          acceptor: acceptor,
          recipient: telegram,
          resource: resource,
          event_type: String.to_existing_atom(event.type.type),
          chat_id: telegram.chat_id
        })
    end
  end
end
