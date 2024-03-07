defmodule Sentinel.Events.Event do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Events.EventType

  @type t :: %__MODULE__{
          id: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "events" do
    field :type, EventType
    field :payload, :map, default: %{}
    field :resource_id, :integer
    field :resource_type, :string
    field :creator_id, :integer
    field :creator_type, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(event, attrs \\ %{}) do
    event
    |> cast(attrs, [:type, :payload, :resource_id, :resource_type, :creator_id, :creator_type])
    |> validate_required([:type])
  end
end
