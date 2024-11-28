defmodule Sentinel.Escalations.Alert do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.User
  alias Sentinel.Escalations.Step
  alias Sentinel.Integrations.Telegram
  alias Sentinel.Integrations.Webhook

  @alert_types ~w[email webhook telegram]a

  schema "escalation_alerts" do
    field :alert_type, Ecto.Enum, values: @alert_types
    belongs_to :user, User
    belongs_to :webhook, Webhook
    belongs_to :telegram, Telegram
    belongs_to :escalation_step, Step

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:user_id, :alert_type])
    |> validate_required([])
  end
end
