defmodule Sentinel.Integrations.TelegramBot do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "telegram_bots" do
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram_bot, attrs) do
    telegram_bot
    |> cast(attrs, [])
    |> validate_required([])
  end
end
