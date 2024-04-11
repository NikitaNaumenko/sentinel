defmodule Sentinel.Events.EventTypes.MonitorUp do
  @moduledoc false

  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :type, :string, default: "monitor_up"
    field :send_email, :boolean, default: true
    field :send_slack, :boolean, default: true
    field :send_webhook, :boolean, default: true
    field :send_telegram, :boolean, default: true
  end
end
