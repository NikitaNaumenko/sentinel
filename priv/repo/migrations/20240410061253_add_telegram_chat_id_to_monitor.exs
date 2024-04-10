defmodule Sentinel.Repo.Migrations.AddTelegramChatIdToMonitor do
  use Ecto.Migration

  def change do
    alter table(:monitor_notification_rules) do
      add :telegram_chat_id, :string
    end
  end
end
