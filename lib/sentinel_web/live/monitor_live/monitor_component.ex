defmodule SentinelWeb.MonitorLive.MonitorComponent do
  use SentinelWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id={@id}>
    <.link
      navigate={~p"/monitors/#{@monitor}"}
      class="flex flex-col items-center bg-white border border-gray-200 rounded-lg shadow md:flex-row md:max-w-xl hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700 mb-5"
    >
      <div class="flex flex-col justify-between p-4 leading-normal">
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
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
end
