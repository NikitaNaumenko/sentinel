defmodule Sentinel.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents) do
      add :started_at, :utc_datetime_usec, null: false
      add :ended_at, :utc_datetime_usec
      add :duration, :integer
      add :status, :string
      add :http_code, :integer
      add :description, :string
      add :monitor_id, references(:monitors, on_delete: :delete_all), null: false
      add :start_check_id, references(:checks, on_delete: :delete_all)
      add :end_check_id, references(:checks, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
