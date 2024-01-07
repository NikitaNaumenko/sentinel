defmodule SentinelWeb.MonitorLive.Show do
  use SentinelWeb, :live_view

  alias Sentinel.Checks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:monitor, Checks.get_monitor!(id))
     |> assign(:current_tab, params["tab"] || "overview")}
  end

  defp page_title(:show), do: "Show Monitor"
  defp page_title(:edit), do: "Edit Monitor"
end
