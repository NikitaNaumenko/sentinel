
defmodule Sentinel.Events.UseCases.SendTelegramTest do
  use Sentinel.DataCase
  use Repatch.ExUnit

  import Sentinel.AccountsFixtures
  import Sentinel.EventsFixtures
  import Sentinel.MonitorsFixtures
  alias Sentinel.IntegrationsFixtures

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
        SendEmail.call(%{
          acceptor: acceptor,
          recipient: user,
          resource: resource,
          event_type: String.to_existing_atom(event.type.type)
        })

      Process.sleep(100)

      email = Sentinel.Events.Notifications.Email.monitor_down(%{monitor: resource, user: user})
      assert_email_sent(email)
    end
  end
end
