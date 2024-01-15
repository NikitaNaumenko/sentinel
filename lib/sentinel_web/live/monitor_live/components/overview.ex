defmodule SentinelWeb.MonitorLive.Components.Overview do
  @moduledoc false

  use SentinelWeb, :component

  def overview(assigns) do
    ~H"""
    <div class="py-5">Last 7 days</div>
    <div class="flex w-full justify-between gap-4">
      <div class="max-w-7xl">
        <div>
          <div class="mb-4 grid grid-cols-4">
            <div class="block rounded-l-lg border border-gray-200 bg-white p-3 shadow dark:border-gray-700 dark:bg-gray-800 ">
              <div><%= dgettext("monitors", "Uptime") %></div>
              <div><%= @uptime %>%</div>
            </div>
            <div class="block border-y border-gray-200 bg-white p-3 shadow dark:border-gray-700 dark:bg-gray-800">
              <div>Up for</div>
              <div><%= @uptime_period %></div>
            </div>
            <div class="block border-y border-gray-200 bg-white p-3 shadow dark:border-gray-700 dark:bg-gray-800">
              <div>Avg response time</div>
              <div><%= @avg_response_time %></div>
            </div>
            <div class="block rounded-r-lg border-y border-r border-gray-200 bg-white p-3 shadow dark:border-gray-700 dark:bg-gray-800">
              <div>Incidents</div>
              <div><%= @incidents %></div>
            </div>
          </div>
        </div>
        <div
          class="mb-4 block rounded-lg border border-gray-200 bg-white p-3 shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700"
          id="uptime-monitor"
          data-values={Jason.encode!(@uptime_stats)}
          phx-hook="UptimeMonitorChart"
        >
          <canvas id="uptime-monitor-chart"></canvas>
        </div>
        <div
          class="mb-4 block rounded-lg border border-gray-200 bg-white p-3 shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700"
          data-values={Jason.encode!(@response_times)}
          id="response-time-monitor"
          phx-hook="ResponseTimeMonitorChart"
        >
          <canvas id="response-time-monitor-chart"></canvas>
        </div>
        <%!-- TODO: Incidents will be here --%>
        <div class="mb-4 block rounded-lg border border-gray-200 bg-white shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700">
          <div class="flex flex-wrap border-b border-gray-200 bg-gray-50 p-4 text-center text-sm font-medium text-gray-500 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-400">
            Incidents
          </div>
          <div class=" bg-white p-4 dark:bg-gray-800 md:p-8">
            No incidents
          </div>
        </div>
      </div>

      <div class="w-80">
        <div class="">
          <div class="block rounded-lg border border-gray-200 bg-white p-6 shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700">
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
        <div class="mt-5 block rounded-lg border border-gray-200 bg-white p-6 shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700">
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

        <div class="mt-5 block rounded-lg border border-gray-200 bg-white p-6 shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700">
          <%!-- TODO: --%> Here will be HTTP transcription of checks
        </div>
      </div>
    </div>
    """
  end
end
