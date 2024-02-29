defmodule Sentinel.Events.Acceptors.Webhook do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Acceptors.WebhookFsm
  alias Sentinel.Integrations.Webhook

  @states WebhookFsm.states()

  schema "event_acceptor_webhook" do
    field :payload, :map, default: %{}
    field :state, Ecto.Enum, values: @states, default: :*
    belongs_to :webhook, Webhook
    belongs_to :acceptor, Acceptor
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:payload, :webhook_id, :acceptor_id])
    |> validate_required([:payload, :webhook_id, :acceptor_id])
  end
end
