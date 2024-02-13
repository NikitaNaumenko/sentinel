defmodule Sentinel.Events.Acceptors.Webhook do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_acceptor_webhook" do


    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [])
    |> validate_required([])
  end
end
