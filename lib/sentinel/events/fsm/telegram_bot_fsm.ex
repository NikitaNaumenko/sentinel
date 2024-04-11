fsm = """
  created --> |send| sending
  created --> |fail| failed
  sending --> |finish| sent
  sending --> |fail| failed
"""

defmodule Sentinel.Events.Fsm.TelegramBotFsm do
  @moduledoc "FSM implementation for `Sentinel.Events.TelegramBot`"
  use Finitomata, fsm: fsm, auto_terminate: true, persistency: Finitomata.Persistency.Protocol

  @impl Finitomata
  def on_transition(:created, :send, _event_payload, state_payload), do: {:ok, :sending, state_payload}
  def on_transition(:sending, :finish, _event_payload, state_payload), do: {:ok, :sent, state_payload}
  def on_transition(:created, :fail, _event_payload, state_payload), do: {:ok, :failed, state_payload}
  def on_transition(:sending, :fail, _event_payload, state_payload), do: {:ok, :failed, state_payload}
end

defimpl Finitomata.Persistency.Persistable, for: Sentinel.Events.Acceptors.TelegramBot do
  @moduledoc """
  Implementation of `Finitomata.Persistency.Persistable` for `TelegramBot`.
  """

  alias Sentinel.Events.Acceptors.TelegramBot
  alias Sentinel.Repo

  require Logger

  def load(%TelegramBot{} = telegram_bot) do
    telegram_bot =
      Repo.insert!(telegram_bot)

    {:created, telegram_bot}
  end

  def store(telegram_bot, %{
        from: _from,
        to: to,
        event: _event,
        event_payload: %{response: response},
        object: telegram_bot
      }) do
    telegram_bot
    |> Ecto.Changeset.change(%{state: to, result: response})
    |> Sentinel.Repo.update()
  end

  def store(telegram_bot, %{
        from: _from,
        to: to,
        event: _event,
        event_payload: _event_payload,
        object: telegram_bot
      }) do
    telegram_bot
    |> Ecto.Changeset.change(%{state: to})
    |> Sentinel.Repo.update()
  end

  def store_error(_telegram_bot, _reason, _info) do
    # TODO: Обработка ошибок
    :ok
  end
end
