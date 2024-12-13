defmodule SentinelWeb.Components.Badge do
  @moduledoc """
  A stateless component for rendering a badge.

  This component can be used to display small pieces of information, like status labels, tags, or counters.
  """

  use Phoenix.Component
  use CVA.Component

  @doc """
  Renders the Badge component.

  ## Options

  ## Example

      <.badge>Badge<./badge>
      <.badge variant="secondary">Badge<./badge>
      <.badge variant="danger">Badge<./badge>
        
  """

  variant(
    :variant,
    [
      primary: "border-transparent bg-primary text-primary-foreground hover:bg-primary/90",
      secondary: "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
      outline: "text-foreground",
      danger: "border-transparent bg-danger text-danger-foreground hover:bg-danger/80",
      success: "border-transparent bg-success text-success-foreground hover:bg-success/80"
    ],
    default: :primary
  )

  def badge(assigns) do
    ~H"""
    <div class={["inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:ring-ring focus:outline-none focus:ring-2 focus:ring-offset-2", @cva_class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
