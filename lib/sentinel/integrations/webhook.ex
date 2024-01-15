defmodule Sentinel.Integrations.Webhook do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.Account

  schema "webhooks" do
    field :endpoint, :string
    belongs_to :account_id, Account

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(webhook, attrs \\ %{}) do
    webhook
    |> cast(attrs, [:endpoint])
    |> validate_required([:endpoint])
  end
end
