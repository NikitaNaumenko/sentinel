defmodule Sentinel.Repo.Migrations.CreatePages do
  use Ecto.Migration
  import EctoEnumMigration

  def change do
    create_type(:page_states, [:draft, :published, :deleted])

    create table(:pages) do
      add :name, :string
      add :slug, :string
      add :website, :string
      add :state, :page_states
      add :public, :boolean
      add :account_id, references(:accounts, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
