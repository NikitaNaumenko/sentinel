defmodule Sentinel.StatusPages.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "page_sections" do


    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [])
    |> validate_required([])
  end
end
