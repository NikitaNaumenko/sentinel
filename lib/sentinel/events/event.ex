defmodule Sentinel.Events.Event do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.Account

  @type t :: %__MODULE__{
          id: integer(),
          # endpoint: String.t(),
          # account_id: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "events" do
    field :endpoint, :string
    field :type, EventType

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs \\ %{}) do
    webhook
    |> cast(attrs, [:endpoint, :account_id])
    |> validate_required([:endpoint, :account_id])
    |> validate_url(:endpoint)
  end
end
