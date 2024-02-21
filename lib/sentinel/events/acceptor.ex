defmodule Sentinel.Events.Acceptor do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Repo

  schema "event_acceptors" do
    # TODO: always user
    belongs_to :event, Sentinel.Events.Event
    belongs_to :recipient, Sentinel.Accounts.User
    field :state, :string
    timestamps(type: :utc_datetime_usec)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  @doc false
  def changeset(acceptor, attrs) do
    acceptor
    |> cast(attrs, [:recipient_id, :event_id, :state])
    |> validate_required([])
  end
end
