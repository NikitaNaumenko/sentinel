defmodule Sentinel.Notifications.Notification do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "notifications" do
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [])
    |> validate_required([])
  end
end
