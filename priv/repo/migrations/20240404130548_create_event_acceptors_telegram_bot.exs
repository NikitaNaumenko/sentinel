defmodule Sentinel.Repo.Migrations.CreateEventAcceptorsTelegramBot do
  use Ecto.Migration

  def change do
    create table(:event_acceptors_telegram_bot) do
      add :state, :string
      add :result, :map, default: %{}
      add :telegram_bot_id, references(:telegram_bots, on_delete: :nothing)
      add :acceptor_id, references(:event_acceptors, on_delete: :nothing)
      timestamps(type: :utc_datetime_usec)
    end
  end
end
