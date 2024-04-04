defmodule Sentinel.Monitors.Check do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Monitors.Monitor

  schema "checks" do
    field :result, Ecto.Enum, values: [:undefined, :success, :failure]
    field :reason, :string
    field :raw_response, :map, default: %{}
    field :duration, :integer
    field :status_code, :integer

    belongs_to :monitor, Monitor
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:result, :reason, :raw_response, :duration, :status_code, :monitor_id])
    |> validate_required([:result, :raw_response, :duration, :status_code, :monitor_id])
    |> assoc_constraint(:monitor)
  end

  def define_result(status, status), do: :success
  def define_result(_expected_status, _actual_status), do: :failure

  # TODO: Возможно тут произошла ерунда и событие должно быть связано с монитором
  def to_payload(%__MODULE__{result: :failure} = check) do
    %{
      event_type: :monitor_down,
      resource_type: to_string(Sentinel.Monitors.Monitor),
      resource_id: check.monitor_id
    }
  end
end
