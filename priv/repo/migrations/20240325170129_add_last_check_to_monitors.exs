defmodule Sentinel.Repo.Migrations.AddLastCheckToMonitors do
  use Ecto.Migration

  def change do
    alter table("monitors") do
      add :last_check_id, references("checks", on_delete: :delete_all)
    end

    create index("monitors", [:last_check_id])
  end
end
