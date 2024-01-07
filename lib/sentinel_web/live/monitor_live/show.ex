defmodule SentinelWeb.MonitorLive.Show do
  use SentinelWeb, :live_view

  alias Sentinel.Checks
  alias Sentinel.Checks.Monitor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    monitor = Checks.get_monitor!(id)

    {:noreply,
     socket
     |> assign(:page_title, monitor.name)
     |> assign(:monitor, monitor)
     |> assign(:current_tab, params["tab"] || "overview")}
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
