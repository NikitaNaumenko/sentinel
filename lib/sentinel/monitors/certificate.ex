defmodule Sentinel.Monitors.Certificate do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Sentinel.Monitors.Monitor

  schema "monitor_certificates" do
    field :issuer, :string
    field :not_after, :utc_datetime_usec
    field :not_before, :utc_datetime_usec
    field :state, Ecto.Enum, values: [:active, :expire_soon, :expired]
    field :subject, :string
    belongs_to :monitor, Monitor
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(certificate, attrs) do
    certificate
    |> cast(attrs, [:issuer, :not_after, :not_before, :subject])
    |> validate_required([:issuer, :not_after, :not_before, :subject])
    |> put_state()
  end

  defp put_state(changeset) do
    not_after = Ecto.Changeset.get_change(changeset, :not_after)

    case DateTime.compare(not_after, DateTime.utc_now()) do
      :gt -> put_change(changeset, :state, :active)
      _ -> put_change(changeset, :state, :expired)
    end
  end
end
