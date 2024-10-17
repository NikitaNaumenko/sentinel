defmodule SentinelWeb.MonitorLive.New do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Monitors
  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorPolicy

  on_mount {AuthorizeHook, policy: MonitorPolicy}
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Monitor.changeset(%Monitor{}, %{})

    http_methods =
      Monitor
      |> Ecto.Enum.values(:http_method)
      |> Enum.map(&to_string/1)
      |> Enum.map(fn code -> {String.upcase(code), code} end)

    status_codes = status_codes()
    intervals = Monitor.intervals()
    request_timeouts = Monitor.request_timeouts()

    socket =
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
      |> assign(:page_title, dgettext("monitors", "Create new monitor"))
      |> assign(:title, dgettext("monitors", "New Monitor"))
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"monitor" => monitor_attrs}, socket) do
    changeset =
      %Monitor{}
      |> Monitor.changeset(monitor_attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"monitor" => monitor_attrs}, socket) do
    case Monitors.create_monitor(Map.put(monitor_attrs, "account_id", socket.assigns.current_user.account_id)) do
      {:ok, monitor} ->
        socket =
          socket
          |> put_flash(:success, dgettext("monitors", "Monitor created successfully"))
          |> push_navigate(to: ~p"/monitors/#{monitor}")

        {:noreply, socket}

      {:error, {:already_started, _pid}} ->
        {:noreply, put_flash(socket, :error, dgettext("monitors", "Something went wrong"))}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
