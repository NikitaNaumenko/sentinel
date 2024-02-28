defmodule Sentinel.Events.Acceptor do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Repo

  schema "event_acceptors" do
    field :recipient, Sentinel.Events.Recipient
    field :state, :string
    field :recipient_type, :string

    belongs_to :event, Sentinel.Events.Event
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
    |> cast(attrs, [:event_id, :state, :recipient, :recipient_type])
    |> validate_required([])
  end
end
