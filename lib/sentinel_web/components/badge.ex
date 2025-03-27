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
      primary: "badge text-bg-primary",
      secondary: "badge text-bg-secondary",
      danger: "badge text-bg-danger",
      success: "badge text-bg-success",
      warning: "badge text-bg-warning",
      info: "badge text-bg-info",
      light: "badge text-bg-light"
    ],
    default: :primary
  )

  variant(
    :rounded,
    [
      default: "",
      pill: "rounded-pill"
    ],
    default: :default
  )

  slot :inner_block

  def badge(assigns) do
    ~H"""
    <div class={@cva_class}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
