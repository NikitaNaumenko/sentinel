defmodule Sentinel.Repo.Migrations.CreateMonitors do
  use Ecto.Migration

  def change do
    create table(:monitors) do
      add :name, :string
      add :url, :string
      add :interval, :integer
      add :http_method, :string
      add :request_timeout, :integer
      add :expected_status_code, :integer
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :state, :string
      timestamps(type: :utc_datetime_usec)
    end

    create index(:monitors, [:account_id, :name])
  end
end
