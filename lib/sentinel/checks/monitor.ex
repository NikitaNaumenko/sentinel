defmodule Sentinel.Checks.Monitor do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import EctoCommons.URLValidator

  alias Sentinel.Checks.Certificate
  alias Sentinel.Checks.NotificationRule

  @request_timeouts [1, 3, 5, 10, 15, 30, 60]
  @intervals [15, 30, 60, 120]
  @available_http_status [
    100,
    101,
    102,
    200,
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    226,
    300,
    301,
    302,
    303,
    304,
    305,
    306,
    307,
    308,
    400,
    401,
    402,
    403,
    404,
    405,
    406,
    407,
    408,
    409,
    410,
    411,
    412,
    413,
    414,
    415,
    416,
    417,
    422,
    423,
    424,
    426,
    428,
    429,
    431,
    500,
    501,
    502,
    503,
    504,
    505,
    506,
    507,
    508,
    510,
    511
  ]

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :interval, :integer
    field :http_method, Ecto.Enum, values: [:get, :post, :put, :patch, :head, :options, :delete]
    field :request_timeout, :integer
    field :expected_status_code, :integer
    field :state, Ecto.Enum, values: [:active, :disabled], default: :active

    belongs_to :last_check, Sentinel.Checks.Check
    belongs_to :last_incident, Sentinel.Checks.Incident
    belongs_to :account, Sentinel.Accounts.Account
    has_many :certificates, Certificate
    has_many :incidents, Sentinel.Checks.Incident
    has_many :checks, Sentinel.Checks.Check
    has_one :notification_rule, NotificationRule

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
      :last_incident_id
    ])
    |> cast_assoc(:certificates)
    |> cast_assoc(:notification_rule)
    |> validate_url(:url)
    |> validate_required([
      :name,
      :url,
      :interval,
      :http_method,
      :request_timeout,
      :expected_status_code
    ])
    |> validate_inclusion(:expected_status_code, @available_http_status)
  end

  def intervals, do: @intervals
  def request_timeouts, do: @request_timeouts
end
