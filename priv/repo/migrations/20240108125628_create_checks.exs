defmodule Sentinel.Repo.Migrations.CreateChecks do
  use Ecto.Migration
  import EctoEnumMigration

  def change do
    create_type(:check_results, [:undefined, :success, :failure])

    create table(:checks) do
      add :result, :check_results
      add :reason, :string
      add :raw_response, :map, default: %{}
      add :monitor_id, references(:monitors, on_delete: :delete_all), null: false
      add :duration, :bigint
      add :status_code, :integer

      timestamps(type: :utc_datetime_usec)
    end
  end
end
