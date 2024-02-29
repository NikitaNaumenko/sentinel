fsm = """
  created --> |send| sending
  sending --> |finish| sent
  created --> |fail| failed
"""

defmodule Sentinel.Events.Acceptors.WebhookFsm do
  @moduledoc "FSM implementation for `Sentinel.Events.Webhook`"
  use Finitomata, fsm: fsm, auto_terminate: true, persistency: Finitomata.Persistency.Protocol

  @impl Finitomata
  def on_transition(:created, :send, _event_payload, state_payload), do: {:ok, :sending, state_payload}
  def on_transition(:created, :finish, _event_payload, state_payload), do: {:ok, :sent, state_payload}

  def on_transition(:created, :fail, _event_payload, state_payload), do: {:ok, :sent, state_payload}
end

defimpl Finitomata.Persistency.Persistable, for: Sentinel.Events.Acceptors.Webhook do
  @moduledoc """
  Implementation of `Finitomata.Persistency.Persistable` for `Webhook`.
  """

  require Logger

  alias Sentinel.Events.Acceptors.Webhook

  def load(%Webhook{id: id} = webhook) do
    dbg("load")
    {:loaded, webhook}
  end

  def store(
        webhook,
        %{from: from, to: to, event: event, event_payload: event_payload, object: webhook}
      ) do
    dbg("STORE")
    # webhook
    # |> Ecto.Changeset.change(%{state: to})
    # |> Sentinel.Repo.update()
 end

  def store(webhook, payload) do
    dbg("STORES")
    end

  def store_error(webhook, reason, %{} = info) do
    metadata = Logger.metadata()

    # info
    # |> Map.put(:id, id)
    # |> Map.put(:data, post)
    # |> Map.to_list()
    # |> Logger.metadata()

    Logger.warn("[DB ERROR]: " <> reason)
    Logger.metadata(metadata)
  end
end
