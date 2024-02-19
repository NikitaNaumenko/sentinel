defmodule Sentinel.Events.Acceptors.Email do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "event_acceptor_emails" do
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [])
    |> validate_required([])
  end
end
