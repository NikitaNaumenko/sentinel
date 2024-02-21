defmodule Sentinel.Events.Workers.SendEmail do
  @moduledoc false
  use Oban.Worker, queue: :notifications

  alias Sentinel.Events
  alias Sentinel.Events.UseCases.NotifyAcceptor

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"recipient_id" => recipient_id, "acceptor_id" => acceptor_id}}) do
    #   email = Email.create(%{recipient_id: recipient_id, acceptor_id: acceptor.id, state: "pending"})
    #   # Email.process!(email)
    #   Sentinel.Checks.Notifications.Email.new(%{recip})
    #   Sample.Mailer.deliver(email)
    #   # Email.sent(email)
    # # TODO: изменения стейта емейла
  end
end
