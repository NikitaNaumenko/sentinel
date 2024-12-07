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
  end
end
