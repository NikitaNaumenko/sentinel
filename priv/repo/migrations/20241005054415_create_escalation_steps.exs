defmodule Sentinel.Repo.Migrations.CreateEscalationSteps do
  use Ecto.Migration

  def change do
    create table(:escalation_steps) do
      add :notify_after, :integer
      add :escalation_policy_id, references(:escalation_policies, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
