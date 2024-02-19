defmodule Sentinel.Events.Acceptors.Slack do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "event_acceptor_slack" do
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(slack, attrs) do
    slack
    |> cast(attrs, [])
    |> validate_required([])
  end
end
