defmodule Sentinel.Checks.Notifications.Email do
  @moduledoc false
  import Swoosh.Email

  def monitor_down(monitor, users) do
    new()
    |> to(Enum.map(users, fn user -> {user.email, user.email} end))
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
