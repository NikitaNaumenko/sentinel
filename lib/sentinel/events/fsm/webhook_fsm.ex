fsm = """
  created --> |send| sending
  created --> |fail| failed
  sending --> |finish| sent
  sending --> |fail| failed
"""

defmodule Sentinel.Events.Fsm.WebhookFsm do
  @moduledoc "FSM implementation for `Sentinel.Events.Webhook`"
  use Finitomata, fsm: fsm, auto_terminate: true, persistency: Finitomata.Persistency.Protocol

  @impl Finitomata
  def on_transition(:created, :send, _event_payload, state_payload), do: {:ok, :sending, state_payload}
  def on_transition(:sending, :finish, _event_payload, state_payload), do: {:ok, :sent, state_payload}
  def on_transition(:created, :fail, _event_payload, state_payload), do: {:ok, :failed, state_payload}
  def on_transition(:sending, :fail, _event_payload, state_payload), do: {:ok, :failed, state_payload}
end

defimpl Finitomata.Persistency.Persistable, for: Sentinel.Events.Acceptors.Webhook do
  @moduledoc """
  Implementation of `Finitomata.Persistency.Persistable` for `Webhook`.
  """

  alias Sentinel.Events.Acceptors.Webhook
  alias Sentinel.Repo

  require Logger

  def load(%Webhook{} = webhook) do
    webhook =
      Repo.insert!(webhook)

    {:created, webhook}
  end

  def store(webhook, %{
        from: _from,
        to: to,
        event: _event,
        event_payload: %{response: response},
        object: webhook
      }) do
    response = Jason.decode!(response)

    webhook
    |> Ecto.Changeset.change(%{state: to, result: response})
    |> Sentinel.Repo.update()
  end

  def store(webhook, %{from: _from, to: to, event: _event, event_payload: _event_payload, object: webhook}) do
    webhook
    |> Ecto.Changeset.change(%{state: to})
    |> Sentinel.Repo.update()
  end

  def store_error(_webhook, _reason, _info) do
    # TODO: Обработка ошибок
    :ok
  end
end
