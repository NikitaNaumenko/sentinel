defmodule Sentinel.StatusPages.Page do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Accounts.Account

  schema "pages" do
    field :name, :string
    field :slug, :string
    field :website, :string
    field :state, Ecto.Enum, values: [:draft, :published, :deleted]
    field :public, :boolean, default: false
    belongs_to :account, Account

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :slug, :website, :state, :public])
    |> validate_required([:name])
  end
end
