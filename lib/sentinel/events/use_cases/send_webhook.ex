defmodule Sentinel.Events.UseCases.SendWebhook do
  @moduledoc false
  alias Sentinel.Events.Acceptors.Webhook
  alias Sentinel.Events.Fsm.WebhookFsm
  alias Sentinel.Repo

  require Logger

  def call(%{acceptor: acceptor, recipient: webhook, resource: resource, event_type: event_type}) do
    acceptor = Repo.preload(acceptor, [:event])

    with {:ok, _pid} <-
           create_webhook_acceptor(acceptor, webhook, %{
             event_type: event_type,
             resource_id: resource.id,
             resource_name: to_resource_name(resource),
             payload: acceptor.event.payload
           }),
         :ok <- transition(acceptor.id, :send, %{}),
         {:ok, response} <- do_request(webhook, acceptor.event.payload),
         :ok <- transition(acceptor.id, :finish, %{response: Jason.encode!(response)}) do
      {:ok, :sent}
    else
      {:error, error} ->
        transition(acceptor.id, :fail, %{response: to_string(error)})
        Logger.error(error)
    end
  end

  defp create_webhook_acceptor(acceptor, webhook, payload) do
    attrs = %{
      acceptor_id: acceptor.id,
      webhook_id: webhook.id,
      payload: payload
    }

    Finitomata.start_fsm(WebhookFsm, acceptor.id, struct!(Webhook, attrs))
  end

  defp to_resource_name(resource) do
    resource.__struct__
    |> to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> hd()
    |> String.downcase()
  end

  defp do_request(webhook, payload) do
    :post |> Finch.build(webhook.endpoint, [], Jason.encode!(payload)) |> Finch.request(Sentinel.Finch)
  end

  defp transition(id, event, payload) do
    Finitomata.transition(id, {event, payload})
  end
end
