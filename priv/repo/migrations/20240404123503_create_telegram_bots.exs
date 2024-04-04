defmodule Sentinel.Repo.Migrations.CreateTelegramBots do
  use Ecto.Migration

  def change do
    create table(:telegram_bots) do
      add :token, :string
      add :name, :string

      add :account_id,
          references(:accounts, on_delete: :nothing, type: :integer)

      timestamps(type: :utc_datetime_usec)
    end

    alter table(:monitor_notification_rules) do
      add :telegram_bot_id, references(:telegram_bots, on_delete: :nothing)
    end
  end
end
