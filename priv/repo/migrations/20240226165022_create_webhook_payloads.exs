defmodule Sentinel.Repo.Migrations.CreateWebhookPayloads do
  use Ecto.Migration

  def change do
    create table(:webhook_payloads) do
      timestamps(type: :utc_datetime_usec)
    end
  end
end
