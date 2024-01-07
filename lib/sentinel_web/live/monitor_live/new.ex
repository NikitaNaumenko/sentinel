defmodule SentinelWeb.MonitorLive.New do
  use SentinelWeb, :live_view

  alias Sentinel.Checks
  alias Sentinel.Checks.Monitor

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Monitor.changeset(%Monitor{}, %{})

    http_methods =
      Ecto.Enum.values(Monitor, :http_method)
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
        Enum.map(status_codes, fn {key, value} -> {value, key} end)
        |> Enum.sort_by(fn {_, value} -> value end)
      )
      |> assign(:intervals, intervals)
      |> assign(:request_timeouts, request_timeouts)
      |> assign(:page_title, dgettext("monitors", "New Monitor"))
      |> assign(:title, dgettext("monitors", "New Monitor"))
      |> assign_form(changeset)

    {:ok, socket}
  end

  def header(assigns) do
    ~H"""
    <header class="flex items-center justify-between gap-6 py-2">
      <div>
        <h1 class="text-lg font-semibold leading-8 text-gray-800">
          <%= @page_title %>
        </h1>
      </div>
    </header>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"monitor" => monitor_attrs}, socket) do
    changeset =
      Monitor.changeset(%Monitor{}, monitor_attrs)
      |> Map.put(:action, :validate)

    {:ok, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"monitor" => monitor_attrs}, socket) do
    case Checks.create_monitor(
           Map.put(monitor_attrs, "account_id", socket.assigns.current_user.account_id)
         ) do
      {:ok, monitor} ->
        socket =
          socket
          |> put_flash(:info, dgettext("monitors", "Monitor created successfully"))
          |> push_navigate(to: ~p"/monitors/#{monitor}")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
