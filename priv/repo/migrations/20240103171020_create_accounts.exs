defmodule Sentinel.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:accounts) do
      add :name, :citext

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:accounts, [:name])
  end
end
