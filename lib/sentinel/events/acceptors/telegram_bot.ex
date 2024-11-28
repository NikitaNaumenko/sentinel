defmodule Sentinel.Events.Acceptors.Telegram do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Fsm.TelegramFsm
  alias Sentinel.Integrations.Telegram

  @states TelegramFsm.states()

  schema "event_acceptors_telegram" do
    field :state, Ecto.Enum, values: @states, default: :*
    field :result, :map, default: %{}
    belongs_to :telegram, Telegram
    belongs_to :acceptor, Acceptor

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram, attrs) do
    cast(telegram, attrs, [:payload, :result, :telegram_id, :acceptor_id])
  end
end
