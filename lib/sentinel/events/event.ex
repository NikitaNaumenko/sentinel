defmodule Sentinel.Events.Event do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.Account
  alias Sentinel.Events.EventType

  @type t :: %__MODULE__{
          id: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "events" do
    field :type, EventType
    field :payload, :map
    field :resource_id, :integer
    field :resource_type, :string
    field :creator_id, :integer
    field :creator_type, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs \\ %{}) do
    webhook
    |> cast(attrs, [:endpoint, :account_id])
    |> validate_required([:endpoint, :account_id])
  end
end
