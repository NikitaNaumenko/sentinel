defmodule Sentinel.Events.Acceptors.TelegramBot do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Fsm.TelegramBotFsm
  alias Sentinel.Integrations.TelgramBot

  @states TelegramBotFsm.states()

  schema "event_acceptors_telegram_bot" do
    field :payload, :map, default: %{}
    field :state, Ecto.Enum, values: @states, default: :*
    field :result, :map, default: %{}
    belongs_to :telegram_bot, TelegramBot
    belongs_to :acceptor, Acceptor

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram_bot, attrs) do
    telegram_bot
    |> cast(attrs, [:payload, :state, :result, :telegram_bot_id, :acceptor_id])
    |> cast(attrs, [:payload, :telegram_bot_id, :acceptor_id])
  end
end
