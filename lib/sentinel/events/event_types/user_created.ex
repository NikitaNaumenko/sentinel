defmodule Sentinel.Events.EventTypes.UserCreated do
  @moduledoc false

  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :type, :string, default: "user_created"
    field :send_email, :boolean, default: true
    field :send_slack, :boolean, default: false
    field :send_webhook, :boolean, default: false
    field :send_telegram, :boolean, default: false
  end
end
