defmodule Sentinel.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :type, :string
      add :payload, :map, default: %{}
      add :resource_id, :integer
      add :resource_type, :string
      add :creator_id, :integer
      add :creator_type, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
