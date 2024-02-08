defmodule SentinelWeb.Components.Alert do
  @moduledoc """
  Defines a `Carbon.Alert` component for the Phoenix framework.

  This component is used to display alert messages in a web application. It supports various styles through the `variant` macro and can optionally include an icon. The component is flexible, allowing the insertion of custom content through its slots.

  ## Features

  - Supports different style variants like primary, danger, and success.
  - Optional icon support.
  - Customizable header through the `alert_header` slot.
  - Flexible content insertion via slots.
  """
  use Phoenix.Component
  use CVA.Component

  import SentinelWeb.Components.Icon

  variant(
    :variant,
    [
      primary: "bg-background text-foreground",
      danger: "border-danger/50 text-danger [&>svg]:text-danger",
      success: "border-success/50 text-success [&>svg]:text-success"
    ],
    default: :primary
  )

  attr(:icon, :string, default: nil)
  slot(:alert_header)

  @doc """
    Renders the `Carbon.Alert` component.

  This function creates an alert box with a customizable style, optional icon, and slots for header and content. The alert's appearance is controlled by the `variant` attribute, allowing it to adapt to different contexts like warnings, errors, or success messages.

  ## Options

    - `:variant` - Specifies the style of the alert (primary, danger, success).
    - `:icon` - (Optional) Name of the icon to be displayed in the alert.
    - `:alert_header` - (Optional) Slot for custom header content.

  ## Examples
  <.alert variant="primary" icon="icon-info">This is a primary alert with an icon.</.alert>
  <.alert variant="danger" icon="icon-alert">
  <:alert_header>Attention</:alert_header>
  This is a primary alert with an icon.
  </.alert>

  """
  def alert(assigns) do
    ~H"""
    <div
      role="alert"
      class={["relative w-full rounded-lg border px-4 py-3 text-sm", "[&>.icon+div]:translate-y-[-3px] [&>.icon]:text-foreground [&>.icon]:absolute [&>.icon]:top-4 [&>.icon]:left-4 [&>.icon~*]:pl-7", @cva_class]}
    >
      <.icon :if={@icon} name={@icon} class="icon" />
      <h5 :if={@alert_header} class="mb-1 font-medium leading-none tracking-tight">
        <%= render_slot(@alert_header) %>
      </h5>
      <div class="text-sm [&_p]:leading-relaxed">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
