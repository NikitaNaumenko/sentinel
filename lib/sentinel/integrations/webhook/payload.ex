defmodule Sentinel.Integrations.Webhook.Payload do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Integrations.Webhook

  schema "webhook_payloads" do
    field :payload, :map, default: %{}
    belongs_to :webhook, Webhook
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(payload, attrs) do
    payload
    |> cast(attrs, [:webhook_id, :payload])
    |> validate_required([:webhook_id, :payload])
  end
end
