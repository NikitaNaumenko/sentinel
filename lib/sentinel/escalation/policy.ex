defmodule Sentinel.Escalation.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "escalation_policy" do


    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [])
    |> validate_required([])
  end
end
