defmodule Sentinel.Repo.Migrations.CreateEventAcceptors do
  use Ecto.Migration

  def change do
    create table(:event_acceptors) do

      timestamps(type: :utc_datetime_usec)
    end
  end
end
