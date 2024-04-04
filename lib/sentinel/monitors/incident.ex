defmodule Sentinel.Monitors.Incident do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "incidents" do
    field :started_at, :utc_datetime_usec
    field :ended_at, :utc_datetime_usec
    field :duration, :integer
    field :status, Ecto.Enum, values: [:started, :resolved]
    field :http_code, :integer
    field :description, :string
    belongs_to :monitor, Sentinel.Monitors.Monitor
    belongs_to :start_check, Sentinel.Monitors.Check
    belongs_to :end_check, Sentinel.Monitors.Check

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def start_changeset(incident, attrs) do
    incident
    |> cast(attrs, [
      :started_at,
      :status,
      :http_code,
      :description,
      :monitor_id,
      :start_check_id
    ])
    |> validate_required([:started_at, :status, :monitor_id, :start_check_id, :http_code])
  end

  def end_changeset(incident, attrs) do
    incident
    |> cast(attrs, [
      :ended_at,
      :end_check_id
    ])
    |> validate_required([:ended_at, :end_check_id])
    |> put_change(:duration, DateTime.diff(attrs[:ended_at], incident.started_at))
    |> put_change(:status, :resolved)
  end
end
