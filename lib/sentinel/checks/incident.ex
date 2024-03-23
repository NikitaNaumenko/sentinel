defmodule Sentinel.Checks.Incident do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "incidents" do
    field :started_at, :utc_datetime_usec
    field :ended_at, :utc_datetime_usec
    field :duration, :integer
    field :status, Ecto.Enum, values: [:started, :resolved]
    field :http_code, :string
    field :description, :string
    belongs_to :monitor, Sentinel.Checks.Monitor
    belongs_to :start_check, Sentinel.Checks.Check
    belongs_to :end_check, Sentinel.Checks.Check

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [])
    |> validate_required([])
  end
end
