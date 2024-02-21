defmodule Sentinel.Repo.Migrations.CreateEventAcceptors do
  use Ecto.Migration

  def change do
    create table(:event_acceptors) do
      add :recipient_id, references(:users, on_delete: :delete_all)
      add :event_id, references(:events, on_delete: :delete_all)
      add :state, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
