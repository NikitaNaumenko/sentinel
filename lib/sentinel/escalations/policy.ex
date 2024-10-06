defmodule Sentinel.Escalations.Policy do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.Account
  alias Sentinel.Escalations.Step

  schema "escalation_policies" do
    field :name, :string, default: "New Escalation Policy"
    has_many :escalation_steps, Step, foreign_key: :escalation_policy_id
    belongs_to :account, Account

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [:name, :account_id])
    |> cast_assoc(:escalation_steps, sort_param: :escalation_step_sort, drop_params: :escalation_step_drop)
    |> validate_required([:name])
  end
end
