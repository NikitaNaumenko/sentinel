defmodule Sentinel.Repo.Migrations.CreateSlackWebhooks do
  use Ecto.Migration

  def change do
    create table(:slack_webhooks) do
      add :name, :string, null: false
      add :url, :text, null: false
      add :account_id, references(:accounts), null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
