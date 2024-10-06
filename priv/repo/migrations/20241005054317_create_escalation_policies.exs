defmodule Sentinel.Repo.Migrations.CreateEscalationPolicies do
  use Ecto.Migration

  def change do
    create table(:escalation_policies) do
      add :state, :string
      add :name, :string
      add :trigger_event, :string

      add :account_id, references(:accounts, on_delete: :nothing)
      timestamps(type: :utc_datetime_usec)
    end
  end
end
