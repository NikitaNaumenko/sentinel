defmodule Sentinel.Events.UseCases.SendWebhook do
  @moduledoc false
  alias Sentinel.Events.Acceptors.Webhook
  alias Sentinl.Repo

  def call(%{acceptor: acceptor, recipient: recipient, resource: resource, event_type: event_type}) do
    wehook_acceptor =
      create_webhook_acceptor(acceptor, recipient, %{
        event_type: event_type,
        resource_id: resource.id,
        resource_name: to_resource_name(resource),
        payload: acceptor.event.payload
      })
  end

  defp create_webhook_acceptor(acceptor, webhook, payload) do
    %Webhook{}
    |> Webhook.changeset(%{acceptor_id: acceptor.id, webhook_id: webhook.id, payload: payload})
    |> Repo.insert!()
  end

  defp to_resource_name(resource) do
    resource.__struct__ |> to_string() |> String.split(".") |> Enum.reverse() |> hd() |> String.downcase()
  end
end
