defmodule SentinelWeb.Components.Sidebar do
  @moduledoc false
  use SentinelWeb, :html

  def sidebar(assigns) do
    ~H"""
    <button
      data-drawer-target="default-sidebar"
      data-drawer-toggle="default-sidebar"
      aria-controls="default-sidebar"
      type="button"
      class="mt-2 ml-3 inline-flex items-center rounded-lg p-3 text-sm text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600 sm:hidden"
    >
      <span class="sr-only">Open sidebar</span>
      <.icon name="icon-menu" />
    </button>

    <aside
      id="default-sidebar"
      class="fixed top-0 left-0 z-40 h-screen w-64 -translate-x-full transition-transform sm:translate-x-0"
      aria-label="Sidenav"
    >
      <div class="h-full overflow-y-auto border-r border-gray-200 bg-white px-3 py-5 dark:border-gray-700 dark:bg-gray-800">
        <.link href="#" class="flex items-center mb-5 px-2">
          <img src={~p"/images/logo.svg"} class="me-3 h-6 sm:h-7" alt="Logo" />
          <span class="self-center whitespace-nowrap text-xl font-semibold dark:text-white">
            <%!-- TODO: Truncate --%>
            <%= @current_user.account.name %>
          </span>
        </.link>

        <ul class="space-y-2">
          <li>
            <.sidebar_link
              :if={permit?(Sentinel.Monitors.MonitorPolicy, :index, @current_user)}
              path={~p"/monitors"}
            >
              <.icon
                name="icon-activity-square"
                class="w-6 h-6 text-gray-400 transition duration-75 dark:text-gray-400 group-hover:text-gray-900 dark:group-hover:text-white"
              />
              <span class="ml-3"><%= dgettext("sidebar", "Monitors") %></span>
            </.sidebar_link>
            <.sidebar_link path={~p"/status_pages"}>
              <.icon
                name="icon-radio-tower"
                class="w-6 h-6 text-gray-400 transition duration-75 dark:text-gray-400 group-hover:text-gray-900 dark:group-hover:text-white"
              />
              <span class="ml-3"><%= dgettext("sidebar", "Status pages") %></span>
            </.sidebar_link>
            <.sidebar_link
              :if={permit?(Sentinel.Integrations.IntegrationPolicy, :index, @current_user)}
              path={~p"/integrations"}
            >
              <.icon
                name="icon-blocks"
                class="h-6 w-6 text-gray-400 transition duration-75 group-hover:text-gray-900 dark:text-gray-400 dark:group-hover:text-white"
              />
              <span class="ml-3"><%= dgettext("sidebar", "Integrations") %></span>
            </.sidebar_link>
            <.sidebar_link
              :if={permit?(Sentinel.Teammates.UserPolicy, :index, @current_user)}
              path={~p"/teammates"}
            >
              <.icon
                name="icon-users-round"
                class="h-6 w-6 text-gray-400 transition duration-75 group-hover:text-gray-900 dark:text-gray-400 dark:group-hover:text-white"
              />
              <span class="ml-3"><%= dgettext("sidebar", "Teammates") %></span>
            </.sidebar_link>
          </li>
        </ul>
      </div>
      <div class="absolute bottom-0 left-0 z-20 w-full justify-center space-x-4 border-r border-gray-200 bg-white p-4 dark:border-gray-700 dark:bg-gray-800 lg:flex">
        <.link
          href={~p"/users/log_out"}
          method="delete"
          class="flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group w-full"
        >
          <.icon name="icon-log-out" />
          <span class="ml-3"><%= dgettext("sidebar", "Log out") %></span>
        </.link>
      </div>
    </aside>
    """
  end

  attr :path, :string, required: true
  slot :inner_block, required: true

  defp sidebar_link(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class="flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
