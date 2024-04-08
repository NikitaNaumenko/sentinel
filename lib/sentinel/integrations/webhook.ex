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
    field :name, :string
    field :endpoint, :string
    belongs_to :account, Account

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs \\ %{}) do
    webhook
    |> cast(attrs, [:name, :endpoint, :account_id])
    |> validate_required([:endpoint, :account_id, :name])
    |> validate_length(:name, min: 4)
    |> validate_url(:endpoint)
  end

  def validate_url(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: nil} ->
          [{field, Keyword.get(opts, :message, "is missing a scheme (e.g. https)")}]

        %URI{host: nil} ->
          [{field, Keyword.get(opts, :message, "is missing a host")}]

        %URI{host: host} ->
          get_host_by_name(field, host, opts)
      end
    end)
  end

  defp get_host_by_name(field, host, opts) do
    case :inet.gethostbyname(Kernel.to_charlist(host)) do
      {:ok, _} -> []
      {:error, _} -> [{field, Keyword.get(opts, :message, "invalid host")}]
    end
  end
end
