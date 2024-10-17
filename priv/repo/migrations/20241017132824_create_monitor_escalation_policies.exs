defmodule Sentinel.Repo.Migrations.CreateMonitorEscalationPolicies do
  use Ecto.Migration

  def change do
    create table(:monitor_escalation_policies) do
      add :escalation_policy_id, references(:escalation_policies, on_delete: :nothing)
      add :monitor_id, references(:monitors, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
