defmodule Sentinel.Integrations.Webhook do
  use Ecto.Schema
  import Ecto.Changeset

  schema "webhooks" do
    field :payload, :map
    field :endpoint, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:endpoint, :payload])
    |> validate_required([:endpoint])
  end
end
