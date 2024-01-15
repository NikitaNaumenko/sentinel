defmodule SentinelWeb.MonitorLive.Components.Notifications do
  @moduledoc false
  use SentinelWeb, :component

  alias Sentinel.Checks.Monitor

  def notifications(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-between rounded-lg border border-gray-200 bg-white shadow hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700 md:flex-row">
      <div class="flex flex-col justify-between p-4 leading-normal">
        <h5 class="text-l mb-2 font-bold tracking-tight text-gray-900 dark:text-white">
          <%= dgettext("monitors", "Activate monitoring") %>
        </h5>
        <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
          When unchecked, Sentinel will stop pinging this monitor.
        </p>
      </div>
      <div class="p-4">
        <label
          class="relative inline-flex cursor-pointer items-center"
          phx-click={JS.push("toggle-monitor", value: %{id: @monitor.id})}
        >
          <input type="checkbox" value="" class="peer sr-only" checked={active?(@monitor)} />
          <div class="peer h-7 w-14 rounded-full bg-gray-200 after:content-[''] after:start-[4px] after:absolute after:top-0.5 after:h-6 after:w-6 after:rounded-full after:border after:border-gray-300 after:bg-white after:transition-all peer-checked:bg-primary-600 peer-checked:after:translate-x-full peer-checked:after:border-white peer-focus:ring-primary-300 peer-focus:outline-none peer-focus:ring-4 rtl:peer-checked:after:-translate-x-full dark:border-gray-600 dark:bg-gray-700 dark:peer-focus:ring-primary-800">
          </div>
        </label>
      </div>
    </div>
    """
  end

  defp active?(%Monitor{state: :active}), do: true
  defp active?(_), do: false
end
