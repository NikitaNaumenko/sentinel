defmodule Sentinel.Repo.Migrations.CreateEscalationPolicy do
  use Ecto.Migration

  def change do
    create table(:escalation_policy) do

      timestamps(type: :utc_datetime_usec)
    end
  end
end
