defmodule SentinelWeb.MonitorLive.Components.Notifications do
  @moduledoc false
  use SentinelWeb, :component

  alias Sentinel.Checks.Monitor

  def notifications(assigns) do
    ~H"""
    <div class="bg-card text-card-foreground mb-5 flex flex-col rounded-lg border p-6 shadow-sm md:flex-row">
      <div class="flex w-full items-center justify-between space-x-4">
        <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
          <span>
            <%= dgettext("monitors", "Activate monitoring") %>
          </span>
          <span class="text-muted-foreground text-sm font-normal leading-snug">
            When unchecked, Sentinel will stop pinging this monitor.
          </span>
        </label>
        <div>
          <.switch
            checked={active?(assigns.monitor)}
            on_click={JS.push("toggle-monitor", value: %{id: @monitor.id})}
          />
        </div>
      </div>
    </div>

    <div class="text-muted-foreground text-sm">
      <%= dgettext("monitors", "Notification Rules") %>
    </div>

    <div class="bg-card text-card-foreground flex flex-col rounded-lg border shadow-sm">
      <div class="flex flex-col justify-between p-4 leading-normal">
        <h5 class="text-l mb-2 font-bold tracking-tight text-gray-900 dark:text-white">
          <%= dgettext("monitors", "Team level notifications") %>
        </h5>
        <p class="text-primary mb-3 font-normal">
          You will receive notifications for the enabled channels that are configured. To send emails & SMS to specific teammates, please configure an escalation policy.
        </p>
      </div>
      <div class="flex gap-1">
        <div class="mr-5">
          <.input type="checkbox" id="email" label={dgettext("monitors", "Email to everyone")} name="email" />
        </div>
        <div class="mr-5">
          <.input type="checkbox" id="webhook" label={dgettext("monitors", "Webhook")} name="email" />
        </div>
      </div>
    </div>
    """
  end

  defp active?(%Monitor{state: :active}), do: true
  defp active?(_), do: false
end
