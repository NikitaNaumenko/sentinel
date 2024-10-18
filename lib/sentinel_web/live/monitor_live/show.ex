defmodule SentinelWeb.MonitorLive.Show do
  @moduledoc false
  use SentinelWeb, :live_view

  import SentinelWeb.MonitorLive.MonitorComponent, only: [indicator: 1]

  alias Sentinel.Integrations
  alias Sentinel.Monitors
  alias Sentinel.Monitors.Incident
  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorPolicy
  alias Sentinel.Repo

  on_mount {AuthorizeHook, policy: MonitorPolicy}

  @impl true
  def mount(_params, _session, socket) do
    webhooks = Integrations.list_webhooks(socket.assigns.current_user.account)
    telegram_bots = Integrations.list_telegram_bots(socket.assigns.current_user.account)

    socket =
      socket
      |> assign(:webhooks, webhooks)
      |> assign(:telegram_bots, telegram_bots)

    {:ok, socket, layout: {SentinelWeb.Layouts, :monitor}}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    monitor =
      id
      |> Monitors.get_monitor!()
      |> Repo.preload([:last_check])

    changeset = Monitor.changeset(monitor, %{})

    http_methods =
      Monitor
      |> Ecto.Enum.values(:http_method)
      |> Enum.map(&to_string/1)
      |> Enum.map(fn code -> {String.upcase(code), code} end)

    status_codes = status_codes()
    intervals = Monitor.intervals()
    request_timeouts = Monitor.request_timeouts()
    certificate = Monitors.last_certificate(monitor)

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
     |> assign(:certificate, certificate)
     |> assign(:last_five_checks, Monitors.last_five_checks(monitor))
     |> assign(:last_five_incidents, Monitors.last_five_incidents(monitor))
     |> assign(:last_checked_at, Monitors.last_checked_at(monitor))
     |> assign(:this_month_incidents_count, Monitors.this_month_incidents_count(monitor))
     |> assign(:uptime_stats, Monitors.list_checks_for_uptime_stats(monitor))
     |> assign(:response_times, Monitors.list_checks_for_response_times(monitor))
     |> assign(:uptime, Monitors.calculate_uptime(monitor))
     |> assign(:avg_response_time, Monitors.avg_response_time(monitor))
     |> assign(:incidents, Monitors.count_incidents(monitor))
     |> assign(:uptime_period, Monitors.calculate_uptime_sequence(monitor))
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
    case Monitors.update_monitor(socket.assigns.monitor, monitor_attrs) do
      {:ok, _monitor} ->
        socket =
          put_flash(socket, :info, dgettext("monitors", "Monitor updated successfully"))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("update-webhook-url", _params, socket) do
    {:noreply, put_flash(socket, :info, dgettext("notification_rule", "Webhook url updated!"))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case id |> Monitors.get_monitor!() |> Monitors.delete_monitor() do
      {:ok, _monitor} ->
        socket =
          socket
          |> put_flash(:info, dgettext("monitors", "Monitor deleted successfully"))
          |> push_navigate(to: ~p"/monitors")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, dgettext("monitors", "Monitor cannot be deleted"))}
    end
  end

  # def handle_event("toggle-monitor", %{"id" => id}, socket) do
  #   monitor = id |> Monitors.get_monitor!() |> Repo.preload(:notification_rule)

  #   case Monitors.toggle_monitor(monitor) do
  #     {:ok, monitor} ->
  #       socket =
  #         socket
  #         |> assign(:monitor, monitor)
  #         |> put_flash(:info, dgettext("monitors", "Monitor toggled successfully"))

  #       {:noreply, socket}

  #     {:error, _error} ->
  #       {:noreply, put_flash(socket, :error, dgettext("monitors", "Monitor cannot be toggled"))}
  #   end
  # end

  def header(assigns) do
    ~H"""
    <div class="row g-3 align-items-center">
      <div class="col-auto">
        <.indicator monitor={@monitor} />
      </div>
      <div class="col">
        <h2 class="page-title">
          <%= @monitor.name %>
        </h2>
        <div class="text-secondary">
          <ul class="list-inline list-inline-dots mb-0">
            <%!-- <li class="list-inline-item"><span class="text-green">Up</span></li> --%>
            <li class="list-inline-item">Checked every 3 minutes</li>
          </ul>
        </div>
      </div>
      <div class="col-md-auto ms-auto d-print-none">
        <div class="btn-list">
          <.link navigate={~p"/monitors/#{@monitor}/edit"} class="btn">
            <.icon name="icon-cog" /> <%= dgettext("monitors", "Configure") %>
          </.link>
          <.toggle_button monitor={@monitor} />
        </div>
      </div>
    </div>
    """
  end

  def toggle_button(%{monitor: %Monitor{state: :disabled}} = assigns) do
    ~H"""
    <.button phx-click={JS.push("toggle-monitor", value: %{id: @monitor.id})}>
      <.icon name="icon-play" />
      <%= dgettext("monitors", "Activate monitor") %>
    </.button>
    """
  end

  def toggle_button(%{monitor: %Monitor{state: :active}} = assigns) do
    ~H"""
    <.button phx-click={JS.push("toggle-monitor", value: %{id: @monitor.id})}>
      <.icon name="icon-pause" />
      <%= dgettext("monitors", "Pause monitor") %>
    </.button>
    """
  end

  # def handle_event("validate-webhook-url", params, socket) do
  #   {:noreply, put_flash(socket, :info, dgettext("notification_rule", "Webhook url updated!"))}
  # end
  #
  def incident_status(%{incident: %Incident{status: :started}} = assigns) do
    ~H"""
    <p class="text-danger text-sm">
      <.icon name="icon-alert-triangle" />
      <%= dgettext("monitors", "Started") %>
    </p>
    """
  end

  def incident_status(%{incident: %Incident{status: :resolved}} = assigns) do
    ~H"""
    <p class="text-success text-sm">
      <.icon name="icon-check-circle" />
      <%= dgettext("monitors", "Resolved") %>
    </p>
    """
  end
end
