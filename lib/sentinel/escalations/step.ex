defmodule Sentinel.Escalations.Step do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Escalations.Alert
  alias Sentinel.Escalations.Policy

  schema "escalation_steps" do
    field :notify_after, :integer, default: 0
    field :delete, :boolean, virtual: true
    field :temp_id, :string, virtual: true

    belongs_to :escalation_policy, Policy
    has_many :escalation_alerts, Alert, foreign_key: :escalation_step_id
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(step, attrs \\ %{}) do
    step
    |> cast(attrs, [:notify_after])
    |> cast_assoc(:escalation_alerts)
    |> validate_required([:notify_after])
  end
end
