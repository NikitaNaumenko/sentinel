defmodule Sentinel.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks) do
      add :endpoint, :string
      add :payload, :map

      timestamps(type: :utc_datetime_usec)
    end
  end
end
