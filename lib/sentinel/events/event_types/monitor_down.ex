defmodule Sentinel.Events.EventTypes.MonitorDown do
  @moduledoc false

  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :type, :string, default: "monitor_down"
    field :send_email, :boolean, default: true
    field :send_slack, :boolean, default: true
    field :send_webhook, :boolean, default: true
  end
end
