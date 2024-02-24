defmodule SentinelWeb.Components.Toast do
  @moduledoc false
  use Phoenix.Component
  use CVA.Component

  import SentinelWeb.Components.Icon
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
      info: "info group border bg-background text-foreground",
      error: "danger group border-danger bg-danger text-danger-foreground",
      success: "success group border-success bg-success text-success-foreground",
      warning: "warning group border-warning bg-warning text-warning-foreground"
    ],
    default: :error
  )

  def toast(assigns) do
    ~H"""
    <div id={@id} role="alert" phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}>
      <div class={["group pointer-events-auto relative flex w-full items-center", "justify-between space-x-2 overflow-hidden rounded-md border p-4 pr-6 shadow-lg transition-all", @cva_class]}>
        <div class="grid gap-1">
          <div :if={@title} class="text-sm font-semibold [&+div]:text-xs"><%= @title %></div>
          <div class="text-sm opacity-90"><%= render_slot(@inner_block) %></div>
        </div>
        <button
          type="button"
          class="text-foreground/50 absolute top-1 right-1 rounded-md p-1 opacity-0 transition-opacity group-[&:not(.info)]:text-secondary/50 hover:text-foreground hover:group-[&:not(.info)]:text-secondary focus:opacity-100 focus:outline-none focus:ring-1 focus:group-[&:not(.info)]:ring-secondary focus:group-[&:not(.info)]:ring-secondary group-hover:opacity-100"
          aria-label="close"
        >
          <.icon name="icon-x" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end
end
