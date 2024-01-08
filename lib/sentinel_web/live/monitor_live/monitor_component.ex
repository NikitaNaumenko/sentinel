defmodule SentinelWeb.MonitorLive.MonitorComponent do
  @moduledoc false
  use SentinelWeb, :component

  alias Sentinel.Checks
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
    <span class={["z-10 inline-flex h-6 w-6 shrink-0 animate-pulse items-center justify-center rounded-full ring-0", failure?(@monitor) && "bg-danger-200 dark:bg-danger-900", success?(@monitor) && "bg-success-200 dark:bg-success-900"]}>
      <span class={["flex h-3 w-3 rounded-full", failure?(@monitor) && "bg-danger-500", success?(@monitor) && "bg-success-500"]}>
      </span>
    </span>
    """
  end

  defp failure?(%Monitor{last_check: :failure}), do: true
  defp failure?(_), do: false
  defp success?(%Monitor{last_check: :success}), do: true
  defp success?(_), do: false
end
