defmodule Sentinel.Events.Acceptors.Telegram do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "event_acceptor_telegram" do
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(telegram, attrs) do
    telegram
    |> cast(attrs, [])
    |> validate_required([])
  end
end
