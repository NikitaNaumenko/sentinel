defmodule SentinelWeb.Components.Button do
  @moduledoc """
  A component module for rendering buttons in a Phoenix application.

  The `Carbon.Button` module provides a flexible and customizable button component that can be used across the web application. It supports various variants and sizes, allowing for consistent yet adaptable button styling throughout the application.

  ## Variants
  The button component supports the following variants:
  - "default": Standard button with primary color.
  - "primary": Emphasizes the primary action in a set of buttons.
  - "secondary": Used for less emphasized actions.
  - "ghost": Minimalist button without a background.
  - "link": Styled like a hyperlink.
  - "outline": Button with an outline and transparent background.
  - "danger": Indicates a potentially harmful action.
  - "success": Denotes a successful or positive action.

  ## Sizes
  The button component can be rendered in different sizes:
  - "default": Standard size.
  - "sm": Small size.
  - "md": Medium size.
  - "lg": Large size.
  - "icon": Suitable for buttons containing only an icon.

  ### Usage
  To use the button component, simply include it in your Phoenix templates and specify the desired variant and size.
  """

  use Phoenix.Component
  use CVA.Component

  require Logger

  attr :rest, :global, include: ~w[on_click]
  attr :class, :any, default: ""
  slot :inner_block

  @doc """
  Renders a button component with specified attributes.

  This function takes a map of assigns which includes attributes for variant and size, along with any other HTML attributes. It renders a button element with classes and styles corresponding to the specified variant and size. The button's content is determined by the `inner_block` slot.

  ## Parameters
  - assigns: A map containing the button attributes.

  ## Examples

  <.button variant="primary" size="lg">Save</.button>
  <.button variant="secondary" size="sm">Save</.button>
  """

  def button(assigns) do
    ~H"""
    <button class={["btn btn-primary", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :rest, :global
  slot :inner_block

  def button_link(assigns) do
    ~H"""
    <.link class={["btn", "btn-primary"]} {@rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
