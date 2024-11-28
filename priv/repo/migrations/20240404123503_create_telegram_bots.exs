defmodule Sentinel.Repo.Migrations.CreateTelegrams do
  use Ecto.Migration

  def change do
    create table(:telegrams) do
      add :chat_id, :string
      add :name, :string

      add :account_id,
          references(:accounts, on_delete: :nothing, type: :integer)

      timestamps(type: :utc_datetime_usec)
    end

    alter table(:monitor_notification_rules) do
      add :telegram_id, references(:telegrams, on_delete: :nothing)
    end
  end
end
