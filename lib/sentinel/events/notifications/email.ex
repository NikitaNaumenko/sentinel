defmodule Sentinel.Events.Notifications.Email do
  @moduledoc false
  import Swoosh.Email

  def monitor_down(%{monitor: monitor, user: user}) do
    new()
    |> to({user.email, user.email})
    |> from({"Sentinel", "noreply@sentinel.com"})
    |> subject("⚠️ #{monitor.name} is Down!")
    |> text_body(alert_body(monitor))
  end

  def monitor_up(%{monitor: monitor, user: user}) do
    new()
    |> to({user.email, user.email})
    |> from({"Sentinel", "noreply@sentinel.com"})
    |> subject("✅ #{monitor.name} is up")
    |> text_body(success_body(monitor))
  end

  def teammate_created(%{user: user}) do
    new()
    |> to({user.email, user.email})
    |> from({"Sentinel", "noreply@sentinel.com"})
    |> subject("✅ #{monitor.name} is up")
    |> text_body(invite_body(user))
  end

  defp alert_body(monitor) do
    """
    ==============================

    Sentinel notification: Started an outage
    Your monitor #{monitor.name} is down:

    ------------------------------------------
    Monitor: #{monitor.name}
    Status Code: 500 Internal Server Error
    Started: #{monitor.inserted_at}
    ==============================
    """
  end

  defp success_body(monitor) do
    """
    ==============================
    Sentinel notification: Finished an outage
    Your monitor #{monitor.name} is up:
    ==============================
    """
  end

  defp invite_body(user) do
    """
    ===============================
    Sentinel notification: You were invited
    Follow the link to join Sentinel:
    #{user.invite_url}
    ===============================
    """
  end
end
