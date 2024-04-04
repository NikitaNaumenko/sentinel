defmodule Sentinel.Events.Acceptors.TelegramBot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_acceptors_telegram_bot" do


    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram_bot, attrs) do
    telegram_bot
    |> cast(attrs, [])
    |> validate_required([])
  end
end
