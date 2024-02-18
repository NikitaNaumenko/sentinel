defmodule SentinelWeb.MonitorLive.Components.Overview do
  @moduledoc false

  use SentinelWeb, :component

  def overview(assigns) do
    ~H"""
    <div class="flex w-full justify-between gap-4">
      <div class="ring-offset-background mt-2 space-y-4 focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2">
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight"><%= dgettext("monitors", "Uptime") %></h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold"><%= @uptime %>%</div>
              <p class="text-muted-foreground text-xs">+20.1% from last month</p>
            </div>
          </div>
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">Up for</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold"><%= @uptime_period %></div>
              <p class="text-muted-foreground text-xs">+180.1% from last month</p>
            </div>
          </div>
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">Avg response time</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold"><%= @avg_response_time %></div>
              <p class="text-muted-foreground text-xs">+19% from last month</p>
            </div>
          </div>
          <div class="bg-card text-card-foreground rounded-xl border shadow">
            <div class="flex flex-row items-center justify-between space-y-0 p-6 pb-2">
              <h3 class="text-sm font-medium tracking-tight">Incidents</h3>
            </div>
            <div class="p-6 pt-0">
              <div class="text-2xl font-bold"><%= @incidents %></div>
              <p class="text-muted-foreground text-xs">+201 since last hour</p>
            </div>
          </div>
        </div>
        <div
          id="uptime-monitor"
          data-values={Jason.encode!(@uptime_stats)}
          class="bg-card text-card-foreground col-span-4 rounded-xl border shadow"
        >
          <div class="flex flex-col space-y-1.5 p-6">
            <h3 class="font-semibold leading-none tracking-tight">Uptime</h3>
          </div>
          <div class="p-6 pt-0 pl-2">
            <canvas id="uptime-monitor-chart"></canvas>
          </div>
        </div>
        <div
          class="bg-card text-card-foreground col-span-4 rounded-xl border shadow"
          data-values={Jason.encode!(@response_times)}
          id="response-time-monitor"
        >
          <div class="flex flex-col space-y-1.5 p-6">
            <h3 class="font-semibold leading-none tracking-tight">Response time</h3>
          </div>
          <div class="p-6 pt-0 pl-2">
            <canvas id="response-time-monitor-chart"></canvas>
          </div>
        </div>
        <%!-- TODO: Incidents will be here --%>
        <div class="bg-card text-card-foreground col-span-3 rounded-xl border shadow">
          <div class="flex flex-col space-y-1.5 p-6">
            <h3 class="font-semibold leading-none tracking-tight">Incidents</h3>
            <p class="text-muted-foreground text-sm">You made 265 incidents this month.</p>
          </div>
          <div class="p-6 pt-0">
            <div class="space-y-8">
              <div class="flex items-center">
                <span class="relative flex h-9 w-9 shrink-0 overflow-hidden rounded-full">
                  <img class="aspect-square h-full w-full" alt="Avatar" src="/avatars/01.png" />
                </span>
                <div class="ml-4 space-y-1">
                  <p class="text-sm font-medium leading-none">Olivia Martin</p>
                  <p class="text-muted-foreground text-sm">olivia.martin@email.com</p>
                </div>
                <div class="ml-auto font-medium">+$1,999.00</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="min-w-[326px]">
        <div class="">
          <div class="block rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
            <%= if @certificate do %>
              <h5 class="text-l font-bold tracking-tight text-gray-900 dark:text-white">
                <%= dgettext("monitors", "SSL days remaining") %>
                <.icon name="hero-lock-closed-solid" class="w-6 h-6 text-success-500 mb-2" />
              </h5>
              <div class="py-2">
                <span class="text-success-600 text-2xl font-semibold dark:text-white">
                  30
                </span>
              </div>
              <div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    <%= dgettext("certificates", "Subject") %>
                  </div>
                  <div class="text-gray-500 dark:text-gray-400"><%= @certificate.subject %></div>
                </div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    <%= dgettext("certificates", "Issuer") %>
                  </div>
                  <div class="text-gray-500 dark:text-gray-400"><%= @certificate.issuer %></div>
                </div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    <%= dgettext("certificates", "Valid from") %>
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">
                    <%= Cldr.DateTime.to_string!(@certificate.not_before) %>
                  </div>
                </div>
                <div class="py-1">
                  <div class="text-l font-semibold text-gray-900 dark:text-white">
                    <%= dgettext("certificates", "Valid to") %>
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">
                    <%= Cldr.DateTime.to_string!(@certificate.not_after) %>
                  </div>
                </div>
              </div>
            <% else %>
              <h5 class="text-l font-bold tracking-tight text-gray-900 dark:text-white">
                <%= dgettext("monitors", "No Certificate") %>
                <.icon name="hero-exclamation-triangle" class="w-6 h-6 text-danger-500 mb-2" />
              </h5>
            <% end %>
          </div>
        </div>
        <div class="mt-5 block rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
          <h5 class="text-l font-bold tracking-tight text-gray-900 dark:text-white">
            <%= dgettext("monitors", "Last five checks") %>
          </h5>
          <div :for={check <- @last_five_checks} class="py-2">
            <span class={["me-2 rounded px-2.5 py-0.5 text-xs font-medium", check.result == :success && "bg-success-100 text-success-800 dark:bg-success-900 dark:text-success-300", check.result == :failure && "bg-danger-100 text-danger-800 dark:bg-danger-900 dark:text-danger-300"]}>
              <%= check.status_code %>
            </span>
            <span>
              <%= Sentinel.Cldr.DateTime.Relative.to_string!(check.inserted_at, format: :narrow) %>
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
end
