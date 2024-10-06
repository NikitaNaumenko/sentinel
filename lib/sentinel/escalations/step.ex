defmodule Sentinel.Escalations.Step do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sentinel.Escalation.Policy
  alias Sentinel.Escalation.Alert

  schema "escalation_steps" do
    field :notify_after, :integer, default: 0


    belongs_to :escalation_policy, Policy
    has_many :alerts, Alert
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(step, attrs \\ %{}) do
    step
    |> cast(attrs, [:notify_after])
    |> validate_required([:notify_after])
  end
end
