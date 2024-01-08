defmodule Sentinel.Checks.Check do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Checks.Monitor

  schema "checks" do
    field :result, Ecto.Enum, values: [:undefined, :success, :failure]
    field :reason, :string
    field :raw_response, :map, default: %{}

    belongs_to :monitor, Monitor
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:result, :reason, :raw_response])
    |> validate_required([:result, :raw_response])
  end

  def define_result(status, status), do: :success
  def define_result(_expected_status, _actual_status), do: :failure
end
