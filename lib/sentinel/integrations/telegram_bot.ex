defmodule Sentinel.Integrations.TelegramBot do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "telegram_bots" do
    field :name, :string
    field :token, :string
    belongs_to :account, Sentinel.Account
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram_bot, attrs \\ %{}) do
    telegram_bot
    |> cast(attrs, [:name, :token, :account_id])
    |> validate_required([:name, :token, :account_id])
  end
end
