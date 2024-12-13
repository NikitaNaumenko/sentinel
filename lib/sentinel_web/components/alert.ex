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
      primary: "alert-primary",
      danger: "alert-danger",
      success: "alert-success"
    ],
    default: :primary
  )

  attr(:closable, :boolean, default: true)
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
    <div class={["alert alert-important alert-danger alert-dismissible", @cva_class]} role="alert">
      <div class="d-flex">
        <%!-- <div> --%>
        <.icon :if={@icon} name={@icon} />
        <%!-- </div> --%>
        <div>
          {render_slot(@inner_block)}
        </div>
      </div>
      <a :if={@closable} class="btn-close btn-close-white" data-bs-dismiss="alert" aria-label="close"></a>
    </div>
    """
  end
end
