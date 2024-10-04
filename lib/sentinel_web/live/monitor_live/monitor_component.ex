defmodule SentinelWeb.MonitorLive.MonitorComponent do
  @moduledoc false
  use SentinelWeb, :component

  alias Sentinel.Monitors.Check
  alias Sentinel.Monitors.Monitor

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.link navigate={~p"/monitors/#{@monitor}"} class="card">
        <div class="card-body">
          <h5 class="card-title">
            <.indicator monitor={@monitor} />
            <%= @monitor.name %>
          </h5>
          <p class="text-secondary">
            <%= @monitor.url %>
          </p>
        </div>
      </.link>
    </div>
    """
  end

  def indicator(assigns) do
    ~H"""
    <span class={["status-indicator status-indicator-animated", color(@monitor)]}>
      <span class="status-indicator-circle"></span>
      <span class="status-indicator-circle"></span>
      <span class="status-indicator-circle"></span>
    </span>
    """
  end

  defp color(%Monitor{state: :disabled}), do: "status-secondary"
  defp color(%Monitor{last_check: %Check{result: :failure}}), do: "status-danger"
  defp color(%Monitor{last_check: %Check{result: :success}}), do: "status-success"
  defp color(_), do: "status-warning"
end
