defmodule Sentinel.Events.Acceptors.Email do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.User
  alias Sentinel.Events.Acceptor

  @delivery_status ~w[sent hard-bounce soft-bounce spam unsub custom invalid-sender invalid test-mode-limit rule rejected bounce]
  @states ~w[created processing pending sent failed muted]
  schema "event_acceptor_emails" do
    field :deliviery_status, :string
    field :state, :string

    belongs_to :acceptor, Sentinel.Events.Acceptor
    belongs_to :recipient, Sentinel.Accounts.User
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:state, :delivery_status, :recipient_id, :acceptor_id])
    |> validate_required([:status, :delivery_status, :recipient_id, :acceptor_id])
  end
end
