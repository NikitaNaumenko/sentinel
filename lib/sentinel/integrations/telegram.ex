defmodule Sentinel.Integrations.Telegram do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "telegrams" do
    field :name, :string
    field :chat_id, :string
    belongs_to :account, Sentinel.Account
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram, attrs \\ %{}) do
    telegram
    |> cast(attrs, [:name, :chat_id, :account_id])
    |> validate_required([:name, :chat_id, :account_id])
  end
end
