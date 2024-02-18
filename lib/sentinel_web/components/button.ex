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

  attr :rest, :any, default: []
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

  variant(
    :variant,
    [
      primary: "bg-primary text-primary-foreground hover:bg-primary/90",
      danger: "bg-danger text-danger-foreground hover:bg-danger/90",
      success: "bg-success text-success-foreground hover:bg-success/90",
      outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
      secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground",
      link: "text-primary underline-offset-4 hover:underline"
    ],
    default: :primary
  )

  variant(
    :size,
    [
      md: "h-9 px-4 py-2",
      default: "h-9 px-4 py-2",
      sm: "h-8 rounded-md px-3 text-xs",
      lg: "h-10 rounded-md px-8",
      icon: "h-9 w-9"
    ],
    default: :md
  )

  def button(assigns) do
    ~H"""
    <button
      class={["ring-offset-background inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50", @cva_class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
