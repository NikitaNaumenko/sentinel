defmodule Sentinel.Repo.Migrations.CreateEventAcceptorWebhook do
  use Ecto.Migration

  def change do
    create table(:event_acceptor_webhook) do
      add :acceptor_id, references(:event_acceptors, on_delete: :delete_all)
      add :payload, :map, default: %{}
      add :result, :map, default: %{}
      add :state, :string
      add :webhook_id, references(:webhooks, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
