defmodule Sentinel.Events.UseCases.SendEmailTest do
  use Sentinel.DataCase

  import Sentinel.AccountsFixtures
  import Sentinel.EventsFixtures
  import Sentinel.MonitorsFixtures
  import Swoosh.TestAssertions

  alias Sentinel.Events.UseCases.SendEmail

  setup do
    user = user_fixture()
    monitor = monitor_fixture(%{account_id: user.account_id})
    event = event_fixture(%{type: :monitor_down, resource: monitor})

    acceptor =
      acceptor_fixture(%{
        recipient: %{id: user.id, type: to_string(user.__struct__)},
        event_id: event.id,
        recipient_type: "email"
      })

    [event: event, user: user, resource: monitor, acceptor: acceptor]
  end

  describe "call/1" do
    test "send email", %{user: user, event: event, resource: resource, acceptor: acceptor} do
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
