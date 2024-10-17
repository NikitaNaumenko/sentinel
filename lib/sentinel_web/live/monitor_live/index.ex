defmodule SentinelWeb.MonitorLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Monitors
  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorPolicy
  alias SentinelWeb.MonitorLive.MonitorComponent

  on_mount {AuthorizeHook, policy: MonitorPolicy}
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Monitors.subscribe("monitors-#{socket.assigns.current_user.account_id}")
    monitors = Monitors.list_monitors(socket.assigns.current_account.id)
    monitors_count = Enum.count(monitors)

    socket =
      socket
      |> assign(:page_title, "Listing Monitors")
      |> assign(:monitor, nil)
      |> stream(:monitors, monitors)
      |> assign(:monitors_total_count, monitors_count)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def terminate(_reason, socket) do
    Monitors.unsubscribe("monitors-#{socket.assigns.current_user.account_id}")
  end

  @impl true
  def handle_info({SentinelWeb.MonitorLive.FormComponent, {:saved, monitor}}, socket) do
    {:noreply, stream_insert(socket, :monitors, monitor)}
  end

  def handle_info({:msg, monitor}, socket) do
    {:noreply, stream_insert(socket, :monitors, monitor)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    monitor = Monitors.get_monitor!(id)
    {:ok, _} = Monitors.delete_monitor(monitor)

    {:noreply, stream_delete(socket, :monitors, monitor)}
  end
end
