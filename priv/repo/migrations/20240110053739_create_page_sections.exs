defmodule Sentinel.Repo.Migrations.CreatePageSections do
  use Ecto.Migration

  def change do
    create table(:page_sections) do
      add :name, :string
      add :resource_id, :bigint
      add :resource_type, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
