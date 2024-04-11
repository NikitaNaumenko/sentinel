defmodule Sentinel.Events.Acceptors.TelegramBot do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Fsm.TelegramBotFsm
  alias Sentinel.Integrations.TelegramBot

  @states TelegramBotFsm.states()

  schema "event_acceptors_telegram_bot" do
    field :state, Ecto.Enum, values: @states, default: :*
    field :result, :map, default: %{}
    belongs_to :telegram_bot, TelegramBot
    belongs_to :acceptor, Acceptor

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram_bot, attrs) do
    cast(telegram_bot, attrs, [:payload, :result, :telegram_bot_id, :acceptor_id])
  end
end
