defmodule Sentinel.Events.UseCases.SendEmail do
  @moduledoc false
  # alias Sentinel.Events.Acceptors.Email

  def call(%{acceptor: acceptor, recipient: recipient, resource: resource, event_type: event_type}) do
    # email = create_email(%{recipient_id: recipient.id, acceptor_id: acceptor.id, state: "pending"})

    # TODO Сделать отслеживание email
    Sentinel.Events.Notifications.Email
    |> apply(event_type, [build_args(event_type, resource, recipient)])
    |> Sentinel.Mailer.deliver()

    # TODO Накрутить крутую стейтмашину
    # email
  end

  defp build_args(:monitor_down, resource, recipient) do
    %{monitor: resource, recipient: recipient}
  end

  # defp create_email(attrs) do
  #   %Email{}
  #   |> Email.changeset(attrs)
  #   |> Sentinel.Repo.insert!()
  # end
end
