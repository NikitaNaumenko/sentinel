defmodule SentinelWeb.MonitorLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Checks
  alias Sentinel.Checks.Monitor
  alias SentinelWeb.MonitorLive.MonitorComponent

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Checks.subscribe("monitors-#{socket.assigns.current_user.account_id}")
    {:ok, stream(socket, :monitors, Checks.list_monitors())}
  end

  @impl Phoenix.LiveView
  def terminate(_reason, socket) do
    Checks.unsubscribe("monitors-#{socket.assigns.current_user.account_id}")
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Monitor")
    |> assign(:monitor, Checks.get_monitor!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Monitor")
    |> assign(:monitor, %Monitor{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Monitors")
    |> assign(:monitor, nil)
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
    monitor = Checks.get_monitor!(id)
    {:ok, _} = Checks.delete_monitor(monitor)

    {:noreply, stream_delete(socket, :monitors, monitor)}
  end
end
