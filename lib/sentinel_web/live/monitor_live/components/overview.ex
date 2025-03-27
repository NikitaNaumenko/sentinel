defmodule SentinelWeb.MonitorLive.Components.Overview do
  @moduledoc false

  use SentinelWeb, :component

  alias Sentinel.Monitors.Incident

  def overview(assigns) do
    ~H"""
    <div class="flex w-full justify-between gap-4">
      <div class="ring-offset-background mt-2 space-y-4 focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2">
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">{dgettext("monitors", "Uptime")}</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold">{@uptime}%</div>
            </div>
          </div>
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">Up for</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold">{@uptime_period}</div>
            </div>
          </div>
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">Avg response time</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold">{@avg_response_time}</div>
            </div>
          </div>
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">Incidents</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold">{@incidents}</div>
            </div>
          </div>
        </div>
        <div
          id="uptime-monitor"
          data-values={Jason.encode!(@uptime_stats)}
          phx-hook="UptimeMonitorChart"
          class="bg-card text-card-foreground col-span-4 rounded-xl border shadow"
        >
          <div class="flex flex-col space-y-1.5 p-6">
            <h3 class="font-semibold leading-none tracking-tight">Uptime</h3>
          </div>
          <div class="p-6 pt-0 pl-2">
            <div id="uptime-monitor-chart" phx-update="ignore"></div>
          </div>
        </div>
        <div
          class="bg-card text-card-foreground col-span-4 rounded-xl border shadow"
          data-values={Jason.encode!(@response_times)}
          id="response-time-monitor"
          phx-hook="ResponseTimeMonitorChart"
        >
          <div class="flex flex-col space-y-1.5 p-6">
            <h3 class="font-semibold leading-none tracking-tight">Response time</h3>
          </div>
          <div class="p-6 pt-0 pl-2">
            <div id="response-time-monitor-chart" phx-update="ignore"></div>
          </div>
        </div>
        <div class="bg-card text-card-foreground col-span-3 rounded-xl border shadow">
          <div class="flex flex-col space-y-1.5 p-6">
            <h3 class="font-semibold leading-none tracking-tight">Incidents</h3>
            <p class="text-muted-foreground text-sm">
              <%= if @this_month_incidents_count == 0 do %>
                {dgettext("monitors", "No incidents this month.")}
              <% else %>
                {dgettext("monitors", "You made %{incidents_count} incidents this month.",
                  incidents_count: @this_month_incidents_count
                )}
              <% end %>
            </p>
          </div>
          <div class="p-6 pt-0">
            <div class="space-y-8">
              <div :for={incident <- @last_five_incidents} class="flex justify-between">
                <div class="space-y-1">
                  <p class="text-sm font-medium leading-none">{dgettext("monitors", "Start date")}</p>
                  <p class="text-muted-foreground text-sm">
                    {Cldr.DateTime.to_string!(incident.started_at)}
                  </p>
                </div>
                <div class="space-y-1">
                  <p class="text-sm font-medium leading-none">{dgettext("monitors", "End date")}</p>
                  <p class="text-muted-foreground text-sm">
                    {incident.ended_at && Cldr.DateTime.to_string!(incident.ended_at)}
                  </p>
                </div>
                <div class="space-y-1">
                  <p class="text-sm font-medium leading-none">{dgettext("monitors", "Duration")}</p>
                  <p class="text-muted-foreground text-sm">
                    {incident.duration &&
                      Sentinel.Cldr.DateTime.Relative.to_string!(incident.duration, format: :narrow)}
                  </p>
                </div>
                <.incident_status incident={incident} />
                <div class="space-y-1">
                  <p class="text-sm font-medium leading-none">{dgettext("monitors", "Status code")}</p>
                  <p class="text-muted-foreground text-sm">{incident.http_code}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="min-w-[326px]">
        <div>
          <div class="block rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
            <%= if @certificate do %>
              <h5 class="text-l font-bold tracking-tight text-gray-900 dark:text-white">
                {dgettext("monitors", "SSL days remaining")}
                <.icon name="hero-lock-closed-solid" class="text-success-500 mb-2 h-6 w-6" />
              </h5>
              <div class="py-2">
                <span class="text-success-600 text-2xl font-semibold dark:text-white">
                  30
                </span>
              </div>
              <div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    {dgettext("certificates", "Subject")}
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">{@certificate.subject}</div>
                </div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    {dgettext("certificates", "Issuer")}
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">{@certificate.issuer}</div>
                </div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    {dgettext("certificates", "Valid from")}
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">
                    {Cldr.DateTime.to_string!(@certificate.not_before)}
                  </div>
                </div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    {dgettext("certificates", "Valid to")}
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">
                    {Cldr.DateTime.to_string!(@certificate.not_after)}
                  </div>
                </div>
              </div>
            <% else %>
              <h5 class="text-l font-bold tracking-tight text-gray-900 dark:text-white">
                {dgettext("monitors", "No Certificate")}
                <.icon name="hero-exclamation-triangle" class="text-danger-500 mb-2 h-6 w-6" />
              </h5>
            <% end %>
          </div>
        </div>
        <div class="mt-5 block rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
          <h5 class="text-l font-bold tracking-tight text-gray-900 dark:text-white">
            {dgettext("monitors", "Last five checks")}
          </h5>
          <div :for={check <- @last_five_checks} class="py-2">
            <span class={[
              "me-2 rounded px-2.5 py-0.5 text-xs font-medium",
              check.result == :success &&
                "bg-success-100 text-success-800 dark:bg-success-900 dark:text-success-300",
              check.result == :failure && "bg-danger-100 text-danger-800 dark:bg-danger-900 dark:text-danger-300"
            ]}>
              {check.status_code}
            </span>
            <span>
              {Sentinel.Cldr.DateTime.Relative.to_string!(check.inserted_at, format: :narrow)}
            </span>
          </div>
        </div>

        <div class="mt-5 block rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
          <%!-- TODO: --%> Here will be HTTP transcription of checks
        </div>
      </div>
    </div>
    """
  end

  def incident_status(%{incident: %Incident{status: :started}} = assigns) do
    ~H"""
    <div class="space-y-1">
      <p class="text-sm font-medium leading-none">{dgettext("monitors", "Status")}</p>
      <p class="text-danger text-sm">
        <.icon name="icon-alert-triangle" />
        {dgettext("monitors", "Started")}
      </p>
    </div>
    """
  end

  def incident_status(%{incident: %Incident{status: :resolved}} = assigns) do
    ~H"""
    <div class="space-y-1">
      <p class="text-sm font-medium leading-none">{dgettext("monitors", "Status")}</p>
      <p class="text-success text-sm">
        <.icon name="icon-check-circle" />
        {dgettext("monitors", "Resolved")}
      </p>
    </div>
    """
  end
end
