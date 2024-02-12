defmodule Sentinel.Events.Acceptor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_acceptors" do


    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(acceptor, attrs) do
    acceptor
    |> cast(attrs, [])
    |> validate_required([])
  end
end
