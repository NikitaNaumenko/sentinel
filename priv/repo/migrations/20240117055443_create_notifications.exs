defmodule Sentinel.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
