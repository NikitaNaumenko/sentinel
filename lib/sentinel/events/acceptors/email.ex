defmodule Sentinel.Events.Acceptors.Email do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.User
  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Fsm.EmailFsm

  @delivery_status ~w[sent hard-bounce soft-bounce spam unsub custom invalid-sender invalid test-mode-limit rule rejected bounce]a

  @states EmailFsm.states()

  schema "event_acceptor_emails" do
    field :delivery_status, Ecto.Enum, values: @delivery_status
    field :state, Ecto.Enum, values: @states, default: :*

    belongs_to :acceptor, Acceptor
    belongs_to :user, User
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:state, :delivery_status, :recipient_id, :acceptor_id])
    |> validate_required([:status, :delivery_status, :recipient_id, :acceptor_id])
  end
end
