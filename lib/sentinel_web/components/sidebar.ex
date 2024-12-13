defmodule SentinelWeb.Components.Sidebar do
  @moduledoc false
  use SentinelWeb, :html

  def sidebar(assigns) do
    ~H"""
    <aside class="navbar navbar-vertical navbar-expand-lg">
      <div class="container-fluid">
        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#sidebar-menu"
          aria-controls="sidebar-menu"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="navbar-toggler-icon"></span>
        </button>
        <h1 class="navbar-brand navbar-brand-autodark">
          <.link href="#" class="">
            <img src={~p"/images/logo.svg"} class="navbar-brand-image" alt="Logo" />
          </.link>
          <span class="self-center whitespace-nowrap text-xl font-semibold dark:text-white">
            <%!-- TODO: Truncate --%>
            {@current_user.account.name}
          </span>
        </h1>
        <div class="navbar-nav d-lg-none flex-row">
          <div class="nav-item d-none d-lg-flex me-3">
            <div class="btn-list"></div>
          </div>
        </div>
        <div class="collapse navbar-collapse" id="sidebar-menu">
          <ul class="navbar-nav pt-lg-3">
            <.sidebar_link
              :if={permit?(Sentinel.Monitors.MonitorPolicy, :index, @current_user)}
              path={~p"/monitors"}
            >
              <.icon name="icon-activity-square" class="nav-link-icon d-md-none d-lg-inline-block" />
              <span class="nav-link-title">{dgettext("sidebar", "Monitors")}</span>
            </.sidebar_link>
            <.sidebar_link path={~p"/status_pages"}>
              <.icon name="icon-radio-tower" class="nav-link-icon d-md-none d-lg-inline-block" />
              <span class="nav-link-title">{dgettext("sidebar", "Status pages")}</span>
            </.sidebar_link>
            <.sidebar_link
              :if={permit?(Sentinel.Escalations.EscalationPolicy, :index, @current_user)}
              path={~p"/escalation_policies"}
            >
              <.icon name="icon-arrow-up-narrow-wide" class="nav-link-icon d-md-none d-lg-inline-block" />
              <span class="nav-link-title">{dgettext("sidebar", "Escalation Policies")}</span>
            </.sidebar_link>

            <.sidebar_link
              :if={permit?(Sentinel.Integrations.IntegrationPolicy, :index, @current_user)}
              path={~p"/integrations"}
            >
              <.icon name="icon-blocks" class="nav-link-icon d-md-none d-lg-inline-block" />
              <span class="nav-link-title">{dgettext("sidebar", "Integrations")}</span>
            </.sidebar_link>
            <.sidebar_link
              :if={permit?(Sentinel.Teammates.UserPolicy, :index, @current_user)}
              path={~p"/teammates"}
            >
              <.icon name="icon-users-round" class="nav-link-icon d-md-none d-lg-inline-block" />
              <span class="nav-link-title">{dgettext("sidebar", "Teammates")}</span>
            </.sidebar_link>
            <.link href={~p"/users/log_out"} method="delete">
              <.icon name="icon-log-out" class="nav-link-icon d-md-none d-lg-inline-block" />
              <span class="nav-link-title">{dgettext("sidebar", "Log out")}</span>
            </.link>
          </ul>
        </div>
      </div>
    </aside>
    """
  end

  attr(:path, :string, required: true)
  slot(:inner_block, required: true)

  defp sidebar_link(assigns) do
    ~H"""
    <li class="nav-item">
      <.link class="nav-link" navigate={@path}>
        {render_slot(@inner_block)}
      </.link>
    </li>
    """
  end
end
