defmodule Sentinel.Repo.Migrations.CreateMonitorNotificationRules do
  use Ecto.Migration

  def change do
    create table(:monitor_notification_rules) do
      add :timeout, :integer
      add :resend_interval, :integer
      add :monitor_id, references(:monitors), null: false
      add :via_webhook, :boolean, default: false
      add :via_email, :boolean, default: false
      add :via_slack, :boolean, default: false
      add :via_telegram, :boolean, default: false
      add :webhook_id, references(:webhooks)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
