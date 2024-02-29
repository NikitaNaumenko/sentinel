defmodule Sentinel.Events.UseCases.SendWebhook do
  @moduledoc false
  alias Sentinel.Events.Acceptors.Webhook
  alias Sentinel.Events.Acceptors.WebhookFsm
  alias Sentinel.Repo

  def call(%{acceptor: acceptor, recipient: recipient, resource: resource, event_type: event_type}) do
    acceptor = Repo.preload(acceptor, [:event])

    with {:ok, webhook} <-
           create_webhook_acceptor(acceptor, recipient, %{
             event_type: event_type.type,
             resource_id: resource.id,
             resource_name: to_resource_name(resource),
             payload: acceptor.event.payload
           }),
         :ok <- transition(webhook.id, :send, %{}),
         :ok <- do_request(recipient, webhook.payload),
         :ok <- transition(webhook.id, :finish, %{}) do
      dbg(Repo.reload(webhook))
      :sent
    end
  end

  defp create_webhook_acceptor(acceptor, webhook, payload) do
    webhook =
      %Webhook{}
      |> Webhook.changeset(%{acceptor_id: acceptor.id, webhook_id: webhook.id, payload: payload})
      |> Repo.insert!()

    Finitomata.start_fsm(WebhookFsm, webhook.id, webhook)
    {:ok, webhook}
  end

  defp to_resource_name(resource) do
    resource.__struct__
    |> to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> hd()
    |> String.downcase()
  end

  defp do_request(_, _) do
    :ok
  end

  defp transition(id, event, payload \\ %{}) do
    Finitomata.transition(id, {event, payload})
  end
end
