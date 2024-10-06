defmodule Sentinel.Escalations.Alert do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sentinel.Escalation.Step
  alias Sentinel.Accounts.User
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Integrations.TelegramBot

  @alert_types ~w[email webhook telegram_bot]a

  schema "escalation_alerts" do
    field :alert_types, Ecto.Enum, values: @alert_types
    belongs_to :user, User
    belongs_to :webhook, Webhook
    belongs_to :telegram_bot, TelegramBot
    belongs_to :escalation_step, Step

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [])
    |> validate_required([])
  end
end
