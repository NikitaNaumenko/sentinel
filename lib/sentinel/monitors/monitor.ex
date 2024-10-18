defmodule Sentinel.Monitors.Monitor do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import EctoCommons.URLValidator

  alias Sentinel.Escalations.Policy, as: EscalationPolicy
  alias Sentinel.Monitors.Certificate
  alias Sentinel.Validators.HTTPCodeValidator

  # In seconds
  @request_timeouts [1, 3, 5, 10, 15, 30, 60]
  @intervals [60, 120, 180, 300]

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :interval, :integer
    field :http_method, Ecto.Enum, values: [:get, :post, :put, :patch, :head, :options, :delete]
    field :request_timeout, :integer
    field :expected_status_code, :integer
    field :state, Ecto.Enum, values: [:active, :disabled, :deleted], default: :active

    belongs_to :last_check, Sentinel.Monitors.Check
    belongs_to :last_incident, Sentinel.Monitors.Incident
    belongs_to :account, Sentinel.Accounts.Account
    has_many :certificates, Certificate
    has_many :incidents, Sentinel.Monitors.Incident
    has_many :checks, Sentinel.Monitors.Check
    belongs_to :escalation_policy, EscalationPolicy

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [
      :account_id,
      :name,
      :url,
      :interval,
      :http_method,
      :request_timeout,
      :expected_status_code,
      :last_check_id,
      :last_incident_id,
      :escalation_policy_id
    ])
    |> cast_assoc(:certificates)
    |> validate_url(:url)
    |> validate_required([
      :name,
      :url,
      :interval,
      :http_method,
      :request_timeout,
      :expected_status_code
    ])
    |> HTTPCodeValidator.validate(:expected_status_code)
  end

  def intervals, do: @intervals
  def request_timeouts, do: @request_timeouts
end
