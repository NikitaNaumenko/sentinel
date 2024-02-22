defmodule Sentinel.Events.Notifications.Email do
  @moduledoc false
  import Swoosh.Email

  def monitor_down(%{monitor: monitor, recipient: recipient}) do
    new()
    |> to({recipient.email, recipient.email})
    |> from({"Sentinel", "noreply@sentinel.com"})
    |> subject("⚠️ #{monitor.name} is Down!")
    |> text_body(alert_body(monitor))
  end

  defp alert_body(monitor) do
    """
    ==============================

    Sentinel Alert: Started an outage
    Your monitor #{monitor.name} is down:

    ------------------------------------------
    Monitor: #{monitor.name}
    Status Code: 500 Internal Server Error
    Started: #{monitor.inserted_at}
    ==============================
    """
  end
end
