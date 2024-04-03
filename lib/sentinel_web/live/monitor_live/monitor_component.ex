defmodule SentinelWeb.MonitorLive.MonitorComponent do
  @moduledoc false
  use SentinelWeb, :component

  alias Sentinel.Checks.Check
  alias Sentinel.Checks.Monitor

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.link
        navigate={~p"/monitors/#{@monitor}"}
        class="flex flex-col items-start gap-2 rounded-lg border p-3 text-left text-sm transition-all hover:bg-accent"
      >
        <div class="flex flex-col justify-between leading-normal">
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

  def indicator(assigns) do
    ~H"""
    <span class={["z-10 inline-flex h-6 w-6 shrink-0 animate-pulse items-center justify-center rounded-full ring-0", outer_color_state(@monitor)]}>
      <span class={["flex h-3 w-3 rounded-full", inner_color_state(@monitor)]}></span>
    </span>
    """
  end

  defp outer_color_state(%Monitor{state: :disabled}), do: "bg-secondary/50"
  defp outer_color_state(%Monitor{last_check: %Check{result: :failure}}), do: "bg-danger/50"
  defp outer_color_state(%Monitor{last_check: %Check{result: :success}}), do: "bg-success/50"
  defp outer_color_state(_), do: "bg-warning/50"

  defp inner_color_state(%Monitor{state: :disabled}), do: "bg-secondary"
  defp inner_color_state(%Monitor{last_check: %Check{result: :failure}}), do: "bg-danger"
  defp inner_color_state(%Monitor{last_check: %Check{result: :success}}), do: "bg-success"
  defp inner_color_state(_), do: "bg-warning"
end
