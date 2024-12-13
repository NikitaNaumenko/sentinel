defmodule SentinelWeb.Components.Breadcrumbs do
  @moduledoc """
   Provides a component for rendering breadcrumb navigation in a Phoenix application.

  The `Carbon.Breadcrumbs` component is designed to display a navigational aid in web pages, 
  allowing users to keep track of their locations within the application. It supports custom 
  separator styles and icons for each breadcrumb item.

  ## Usage

  To use the breadcrumbs component, declare it within a Phoenix template and pass the 
  breadcrumb items as slots. Each breadcrumb item can have an optional icon and a path.

  ### Example

      <.breadcrumbs>
        <.breadcrumb_item icon="home-icon" path="/home">Home</.breadcrumb_item>
        <.breadcrumb_item path="/products">Products</.breadcrumb_item>
        <.breadcrumb_item>Current Page</.breadcrumb_item>
      </.breadcrumbs>

  You can also customize the separator by setting the `separator` and `separator_class` attributes.
  """
  use Phoenix.Component

  import SentinelWeb.Components.Icon

  attr :separator, :string, default: "slash"
  attr :separator_class, :string, default: ""

  slot :breadcrumb_item do
    attr :icon, :string
    attr :path, :string
  end

  @doc """
  Renders the breadcrumbs navigation based on the provided breadcrumb items.

  The function generates an HTML structure for breadcrumb navigation. It dynamically creates 
  a list of links or text based on the passed breadcrumb items, separated by a specified 
  separator.

  ## Parameters

    - assigns: A keyword list containing the breadcrumb items and optional configurations.

  ## Example

      <.breadcrumbs separator="icon-chevron-right">
        <:breadcrumb_item path="/home">Home</.breadcrumb_item>
        <:breadcrumb_item icon="icon-users" path="/users">Users</.breadcrumb_item>
      </.breadcrumbs>

  """
  def breadcrumbs(assigns) do
    ~H"""
    <nav class="flex" aria-label="Breadcrumb">
      <ol class="inline-flex items-center space-x-1 md:space-x-2">
        <%= for {breadcrumb, i} <- Enum.with_index(@breadcrumb_item) do %>
          <%= if i > 0 do %>
            <.separator name={@separator} class={@separator_class} />
          <% end %>
          <li class="inline-flex items-center">
            <.icon :if={breadcrumb[:icon]} name={breadcrumb[:icon]} class="mr-1" />
            <.link
              navigate={breadcrumb[:path]}
              class="inline-flex items-center text-sm font-medium hover:underline"
            >
              {render_slot(breadcrumb)}
            </.link>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end

  defp separator(%{name: "slash"} = assigns) do
    ~H"""
    <div class={["px-3 text-lg", @class]}>/</div>
    """
  end

  defp separator(%{name: _name} = assigns) do
    ~H"""
    <.icon name={@name} class="px-3" />
    """
  end
end
