defmodule Sentinel.Repo.Migrations.CreateMonitors do
  use Ecto.Migration
  import EctoEnumMigration

  def change do
    create_type(:http_methods, [:get, :post, :put, :patch, :head, :options, :delete])
    create_type(:monitor_states, [:active, :disabled])

    create table(:monitors) do
      add :name, :string
      add :url, :string
      add :interval, :integer
      add :http_method, :http_methods
      add :request_timeout, :integer
      add :expected_status_code, :integer
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :state, :monitor_states
      timestamps(type: :utc_datetime_usec)
    end

    create index(:monitors, [:account_id, :name])
  end
end
