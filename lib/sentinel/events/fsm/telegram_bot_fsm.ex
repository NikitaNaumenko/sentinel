fsm = """
  created --> |send| sending
  created --> |fail| failed
  sending --> |finish| sent
  sending --> |fail| failed
"""

defmodule Sentinel.Events.Fsm.TelegramFsm do
  @moduledoc "FSM implementation for `Sentinel.Events.Telegram`"
  use Finitomata, fsm: fsm, auto_terminate: true, persistency: Finitomata.Persistency.Protocol

  @impl Finitomata
  def on_transition(:created, :send, _event_payload, state_payload), do: {:ok, :sending, state_payload}
  def on_transition(:sending, :finish, _event_payload, state_payload), do: {:ok, :sent, state_payload}
  def on_transition(:created, :fail, _event_payload, state_payload), do: {:ok, :failed, state_payload}
  def on_transition(:sending, :fail, _event_payload, state_payload), do: {:ok, :failed, state_payload}
end

defimpl Finitomata.Persistency.Persistable, for: Sentinel.Events.Acceptors.Telegram do
  @moduledoc """
  Implementation of `Finitomata.Persistency.Persistable` for `Telegram`.
  """

  alias Sentinel.Events.Acceptors.Telegram
  alias Sentinel.Repo

  require Logger

  def load(%Telegram{} = telegram) do
    telegram =
      Repo.insert!(telegram)

    {:created, telegram}
  end

  def store(telegram, %{
        from: _from,
        to: to,
        event: _event,
        event_payload: %{response: response},
        object: telegram
      }) do
    telegram
    |> Ecto.Changeset.change(%{state: to, result: response})
    |> Sentinel.Repo.update()
  end

  def store(telegram, %{
        from: _from,
        to: to,
        event: _event,
        event_payload: _event_payload,
        object: telegram
      }) do
    telegram
    |> Ecto.Changeset.change(%{state: to})
    |> Sentinel.Repo.update()
  end

  def store_error(_telegram, _reason, _info) do
    # TODO: Обработка ошибок
    :ok
  end
end
