defmodule SentinelWeb.EscalationPolicyLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Escalations
  alias Sentinel.Escalations.EscalationPolicy
  # alias Sentinel.Escalations.Policy

  on_mount {AuthorizeHook, policy: EscalationPolicy}
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    socket =
      socket
      |> assign(:page_title, dgettext("escalation_policies", "Escalation Policies"))
      |> assign(:escalation_policies, Escalations.list_escalation_policies(socket.assigns.current_account.id))

    {:noreply, socket}
  end

  def header(assigns) do
    ~H"""
    <header class="d-flex">
      <div class="col">
        <h2 class="page-title">
          <%= dgettext("escalation_policies", "Escalation Policies") %>
        </h2>
      </div>
      <div class="ms-auto d-print-none col-auto">
        <.link
          :if={permit?(Sentinel.Escalations.EscalationPolicy, :create, @current_user)}
          navigate={~p"/escalation_policies/new"}
          class="btn btn-primary"
        >
          <%= dgettext("escalation_policies", "New escalation policy") %>
        </.link>
      </div>
    </header>
    """
  end
end
