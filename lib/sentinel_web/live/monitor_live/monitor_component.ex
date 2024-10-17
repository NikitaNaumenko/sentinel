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
          <div class="card-title d-flex">
            <.indicator monitor={@monitor} />
            <div class="ms-2">
              <%= @monitor.name %>
              <p class="text-secondary fs-4 fw-normal">
                <%= @monitor.url %>
              </p>
            </div>
          </div>
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
