defmodule Sentinel.Events.Acceptor do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Repo

  schema "event_acceptors" do
    # TODO: always user
    belongs_to :event, Sentinel.Events.Event
    field :state, :string
    field :recipient_id, :integer
    field :recipient_type, :string
    field :recipient, Recipient, virtual: true
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
    |> cast(attrs, [:recipient_id, :recipient_type, :event_id, :state])
    |> validate_required([])
  end
end
