defmodule SentinelWeb.Components.Card do
  @moduledoc """
  A component for creating versatile card layouts in Phoenix applications.

  The `Carbon.Card` component provides a flexible way to build card-based UIs. 
  It supports various layouts and can be easily integrated into Phoenix templates.
  The component includes slots for custom content and offers a variant attribute 
  for layout orientation.

  ## Attributes

  - `class`: Custom CSS classes to be applied to the card.
  - `variant`: Determines the layout orientation of the card. Options are `:vertical` and `:horizontal`.

  ## Slots

  - `inner_block`: A slot for inserting custom content into different parts of the card (header, content, footer).

  ## Variants

  - `:vertical`: Default layout with vertical orientation.
  - `:horizontal`: Layout with horizontal orientation.

  ## Example Usage

      <.card variant="horizontal" class="custom-class">
        <.card_header>Header Content</.card_header>
        <.card_content>Main Content</.card_content>
        <.card_footer>Footer Content</.card_footer>
      </.card>
  """
  use Phoenix.Component
  use CVA.Component

  variant(
    :variant,
    [
      vertical: "",
      horizontal: "flex flex-col items-center md:flex-row"
    ],
    default: :vertical
  )

  attr :class, :string, default: ""

  @doc """
  Renders the main card component with the specified attributes and content.

  This function generates the outer structure of the card component and applies 
  the specified classes. It renders the content provided in the `inner_block` slot.

  ## Parameters

    - assigns: A keyword list containing attributes and content for the card component.

  ## Returns

    - Safe HTML structure for the card component.

  ## Example

      card(assigns)

  """
  def card(assigns) do
    ~H"""
    <div class={["bg-card text-card-foreground rounded-lg border shadow-sm", @class, @cva_class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block

  @doc """
  Renders the header part of the card component.

  This function creates the header section of the card. It applies custom classes 
  and renders content defined in the `inner_block` slot.

  ## Parameters

    - assigns: A keyword list containing attributes and content for the card header.

  ## Returns

    - HTML structure for the card header.

  ## Example

      card_header(assigns)

  """
  def card_header(assigns) do
    ~H"""
    <div class={["flex flex-col space-y-1.5 p-6", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block

  @doc """
  Renders the content part of the card component.

  This function is responsible for displaying the main content of the card. 
  It allows the addition of custom classes and slots in content using the `inner_block`.

  ## Parameters

    - assigns: Attributes and content for the card content.

  ## Returns

    - HTML structure for the card content.

  ## Example

      card_content(assigns)

  """
  def card_content(assigns) do
    ~H"""
    <div class={["p-6 pt-0", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block

  @doc """
  Renders the footer part of the card component.

  Provides a section for card footer content, applying any custom classes specified 
  and rendering the content in the `inner_block` slot.

  ## Parameters

    - assigns: Attributes and content for the card footer.

  ## Returns

    - HTML structure for the card footer.

  ## Example

      card_footer(assigns)

  """
  def card_footer(assigns) do
    ~H"""
    <div class={["flex items-center p-6 pt-0", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
