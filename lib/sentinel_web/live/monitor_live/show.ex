defmodule SentinelWeb.MonitorLive.Show do
  @moduledoc false
  use SentinelWeb, :live_view

  import SentinelWeb.MonitorLive.MonitorComponent, only: [indicator: 1]

  alias Sentinel.Checks
  alias Sentinel.Checks.Monitor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    monitor = Checks.get_monitor!(id)

    changeset = Monitor.changeset(monitor, %{})

    http_methods =
      Monitor
      |> Ecto.Enum.values(:http_method)
      |> Enum.map(&to_string/1)
      |> Enum.map(fn code -> {String.upcase(code), code} end)

    status_codes = status_codes()
    intervals = Monitor.intervals()
    request_timeouts = Monitor.request_timeouts()

    {:noreply,
     socket
     |> assign(:http_methods, http_methods)
     |> assign(
       :status_codes,
       status_codes
       |> Enum.map(fn {key, value} -> {value, key} end)
       |> Enum.sort_by(fn {_, value} -> value end)
     )
     |> assign(:intervals, intervals)
     |> assign(:request_timeouts, request_timeouts)
     |> assign(:page_title, monitor.name)
     |> assign(:monitor, monitor)
     |> assign(:current_tab, params["tab"] || "overview")
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"monitor" => monitor_attrs}, socket) do
    changeset =
      socket.assigns.monitor
      |> Monitor.changeset(monitor_attrs)
      |> Map.put(:action, :validate)

    {:ok, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"monitor" => monitor_attrs}, socket) do
    case Checks.update_monitor(socket.assigns.monitor, monitor_attrs) do
      {:ok, _monitor} ->
        socket =
          put_flash(socket, :info, dgettext("monitors", "Monitor updated successfully"))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case id |> Checks.get_monitor!() |> Checks.delete_monitor() do
      {:ok, _monitor} ->
        socket =
          socket
          |> put_flash(:info, dgettext("monitors", "Monitor deleted successfully"))
          |> push_redirect(to: ~p"/monitors")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, dgettext("monitors", "Monitor cannot be deleted"))}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
