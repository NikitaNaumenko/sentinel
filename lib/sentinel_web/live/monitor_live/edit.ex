defmodule SentinelWeb.MonitorLive.Edit do
  @moduledoc false
  use SentinelWeb, :live_view

  # import SentinelWeb.MonitorLive.Components.Overview, only: [overview: 1]
  # import SentinelWeb.MonitorLive.MonitorComponent, only: [indicator: 1]
  import SentinelWeb.MonitorLive.MonitorComponent, only: [indicator: 1]

  alias Sentinel.Integrations
  alias Sentinel.Monitors
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
     |> assign(:current_tab, params["tab"] || "settings")
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
          put_flash(socket, :success, dgettext("monitors", "Monitor updated successfully"))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Monitors.delete_monitor(id) do
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

  def handle_event("toggle-monitor", %{"id" => id}, socket) do
    monitor = Monitors.get_monitor!(id)

    case Monitors.toggle_monitor(monitor) do
      {:ok, monitor} ->
        socket =
          socket
          |> assign(:monitor, monitor)
          |> put_flash(:info, dgettext("monitors", "Monitor toggled successfully"))

        {:noreply, socket}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, dgettext("monitors", "Monitor cannot be toggled"))}
    end
  end

  def handle_event("update-webhook-url", _params, socket) do
    {:noreply, put_flash(socket, :info, dgettext("notification_rule", "Webhook url updated!"))}
  end

  def handle_info({_, {:updated, _}}, socket) do
    {:noreply, put_flash(socket, :success, dgettext("monitors", "Monitor updated successfully"))}
  end

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
          <.link navigate={~p"/monitors/#{@monitor}"} class="btn">
            <.icon name="icon-arrow-big-left" /> Back
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
end
