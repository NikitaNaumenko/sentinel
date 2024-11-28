defmodule Sentinel.Repo.Migrations.CreateEscalationAlerts do
  use Ecto.Migration

  def change do
    create table(:escalation_alerts) do
      add :escalation_step_id, references(:escalation_steps, on_delete: :nothing)
      # I dont like it, but it looks like compromise solution
      # because we dont have a lot integration
      add :user_id, references(:users, on_delete: :nothing)
      add :webhook_id, references(:webhooks, on_delete: :nothing)
      add :telegram_id, references(:telegrams, on_delete: :nothing)
      add :alert_type, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
