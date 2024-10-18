defmodule Sentinel.Repo.Migrations.AddEscalationPolicyIdToMonitors do
  use Ecto.Migration

  def change do
    alter table("monitors") do
      add :escalation_policy_id, references(:escalation_policies, on_delete: :nothing)
    end
  end
end
