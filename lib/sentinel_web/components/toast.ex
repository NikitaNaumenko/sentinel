defmodule SentinelWeb.Components.Toast do
  @moduledoc false
  use Phoenix.Component
  use CVA.Component

  import SentinelWeb.Components.JsUtils

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """

  attr :id, :string, default: "id", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  variant(
    :kind,
    [
      info: "alert-info",
      danger: "alert-danger",
      success: "alert-success",
      warning: "alert-warning"
    ],
    default: :danger
  )

  def toast(assigns) do
    ~H"""
    <div id={@id} class={["alert alert-dismissible", @cva_class]} role="alert">
      <div class="d-flex">
        <div>
          <h4 :if={@title} class="alert-title">{@title}</h4>
          <div class="text-secondary">{render_slot(@inner_block)}</div>
        </div>
      </div>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>

      <%!-- <a class="btn-close" data-bs-dismiss="alert" aria-label="close"></a> --%>
    </div>
    """
  end
end
