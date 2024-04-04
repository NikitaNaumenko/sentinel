defmodule Sentinel.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks) do
      add :name, :string
      add :endpoint, :string
      add :account_id, references(:accounts), null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
