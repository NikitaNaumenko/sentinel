defmodule Sentinel.Repo.Migrations.CreateMonitorCertificates do
  use Ecto.Migration
  import EctoEnumMigration

  def change do
    create_type(:certificate_states, [:active, :expire_soon, :expired])

    create table(:monitor_certificates) do
      add :issuer, :string
      add :state, :certificate_states
      add :not_after, :utc_datetime_usec
      add :not_before, :utc_datetime_usec
      add :subject, :string
      add :monitor_id, references(:monitors, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
