defmodule Sentinel.Escalations do
  @moduledoc false
  import Ecto.Query

  alias Sentinel.Escalations.Alert
  alias Sentinel.Escalations.Policy
  alias Sentinel.Repo

  @doc """
  Get list of escalation policy by account id
  """
  def list_escalation_policies(account_id) do
    Repo.all(from(p in Policy, where: p.account_id == ^account_id))
  end

  def escalation_policy_changeset(policy \\ %Policy{}, attrs \\ %{}) do
    Policy.changeset(policy, attrs)
  end

  def alert_types do
    Ecto.Enum.values(Alert, :alert_types)
  end
end
