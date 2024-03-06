defmodule Sentinel.Repo.Migrations.CreateEventAcceptorEmails do
  use Ecto.Migration

  def change do
    create table(:event_acceptor_emails) do
      add :acceptor_id, references(:event_acceptors, on_delete: :delete_all)
      add :delivery_status, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :state, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
