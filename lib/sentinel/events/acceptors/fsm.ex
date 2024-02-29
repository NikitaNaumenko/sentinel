fsm = """
  created --> |send| sent
  created --> |fail| failed
"""

defmodule Sentinel.Events.Acceptors.WebhookFsm do
  @moduledoc "FSM implementation for `Sentinel.Events.Webhook`"
  use Finitomata, fsm: fsm, auto_terminate: true
  # , persistency: Finitomata.Persistency.Protocol

  @impl Finitomata
  def on_transition(:created, :send, _event_payload, state_payload), do: {:ok, :sent, state_payload}

  def on_transition(:created, :fail, _event_payload, state_payload), do: {:ok, :sent, state_payload}
end
