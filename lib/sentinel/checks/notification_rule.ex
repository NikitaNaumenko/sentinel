defmodule Sentinel.Checks.NotificationRule do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Checks.Monitor

  schema "monitor_notification_rules" do
    field :timeout, Ecto.Enum,
      values: [instantly: 0, "1": 1, "2": 2, "3": 3, "5": 5, "10": 10, "30": 30, "60": 60, never: -1],
      default: :instantly

    field :resend_interval, Ecto.Enum,
      values: [never: 0, "1": 1, "2": 2, "3": 3, "5": 5, "10": 10, "30": 30, "60": 60],
      default: :never

    field :via_webhook, :boolean, default: false
    field :via_slack, :boolean, default: false
    field :via_email, :boolean, default: false
    field :via_telegram, :boolean, default: false
    belongs_to :monitor, Monitor
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(notification_rule, attrs) do
    cast(notification_rule, attrs, [
      :timeout,
      :resend_interval,
      :via_webhook,
      :via_slack,
      :via_email,
      :via_telegram
    ])
  end
end
