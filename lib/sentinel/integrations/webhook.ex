defmodule Sentinel.Integrations.Webhook do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.Account

  @type t :: %__MODULE__{
          id: integer(),
          endpoint: String.t(),
          account_id: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "webhooks" do
    field :endpoint, :string
    belongs_to :account, Account

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs \\ %{}) do
    webhook
    |> cast(attrs, [:endpoint, :account_id])
    |> validate_required([:endpoint, :account_id])
    |> validate_url(:endpoint)
  end

  def validate_url(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      case_result =
        case URI.parse(value) do
          %URI{scheme: nil} ->
            "is missing a scheme (e.g. https)"

          %URI{host: nil} ->
            "is missing a host"

          %URI{host: host} ->
            case :inet.gethostbyname(Kernel.to_charlist(host)) do
              {:ok, _} -> nil
              {:error, _} -> "invalid host"
            end
        end

      case case_result do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end)
  end
end
