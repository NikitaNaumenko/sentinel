defmodule SentinelWeb.MonitorLive.MonitorComponent do
  use SentinelWeb, :live_component

  alias Sentinel.Checks.Monitor

  def render(assigns) do
    ~H"""
    <div id={@id} class="flex justify-center">
      <.link
        navigate={~p"/monitors/#{@monitor}"}
        class="flex flex-col flex-1 items-center bg-white border border-gray-200 rounded-lg shadow md:flex-row hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700 mb-5"
      >
        <div class="flex flex-col justify-between p-4 leading-normal">
          <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
            <.indicator monitor={@monitor} />
            <%= @monitor.name %>
          </h5>
          <p class="mb-3 font-normal text-gray-500 dark:text-gray-300">
            <%= @monitor.url %>
          </p>
        </div>
      </.link>
    </div>
    """
  end

  defp indicator(assigns) do
    ~H"""
    <span class={[
      "z-10 inline-flex items-center justify-center w-6 h-6 rounded-full ring-0 animate-pulse shrink-0",
      failure?(@monitor) && "dark:bg-danger-900 bg-danger-200",
      success?(@monitor) && "dark:bg-success-900 bg-success-200"
    ]}>
      <span class={[
        "flex w-3 h-3 rounded-full",
        failure?(@monitor) && "bg-danger-500",
        success?(@monitor) && "bg-success-500"
      ]}>
      </span>
    </span>
    """
  end

  defp failure?(%Monitor{last_check: "failure"}), do: true
  defp failure?(_), do: false
  defp success?(%Monitor{last_check: "success"}), do: true
  defp success?(_), do: false
end
