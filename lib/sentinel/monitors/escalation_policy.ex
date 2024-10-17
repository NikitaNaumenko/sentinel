defmodule Sentinel.Monitors.EscalationPolicy do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "monitor_escalation_policies" do
    belongs_to :monitor, Monitor
    belongs_to :escalation_policy, EscalationPolicy

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(escalation_policy, attrs) do
    escalation_policy
    |> cast(attrs, [:monitor_id, :escalation_policy_id])
    |> validate_required([:monitor_id, :escalation_policy_id])
  end
end
