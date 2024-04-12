defmodule Sentinel.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :role, :string, default: "user", null: false
    end
  end
end
