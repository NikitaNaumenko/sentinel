defmodule Sentinel.Repo.Migrations.CreateEventAcceptorsTelegramBot do
  use Ecto.Migration

  def change do
    create table(:event_acceptors_telegram_bot) do
      timestamps(type: :utc_datetime_usec)
    end
  end
end
