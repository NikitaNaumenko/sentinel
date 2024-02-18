defmodule SentinelWeb.Components.Tabs do
  @moduledoc false

  use Phoenix.Component

  attr :current_tab, :string

  slot :tab do
    slot :inner_block
    attr :id, :string, required: true
    attr :patch, :global
  end

  def tabs(assigns) do
    ~H"""
    <div
      role="tablist"
      aria-orientation="horizontal"
      class="bg-muted text-muted-foreground inline-flex h-9 items-center justify-center rounded-lg p-1"
      tabindex="0"
      data-orientation="horizontal"
      style="outline: none;"
    >
      <.link
        :for={tab <- @tab}
        type="button"
        role="tab"
        aria-selected="true"
        aria-controls="radix-:r10:-content-overview"
        data-state="active"
        id={tab[:id]}
        class={[
          "ring-offset-background inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium transition-all focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
          active_tab(tab[:id], @current_tab)
        ]}
        tabindex="0"
        data-orientation="horizontal"
        data-radix-collection-item=""
        patch={tab[:patch]}
      >
        <%= render_slot(tab) %>
      </.link>
    </div>
    """
  end

  def active_tab(tab, tab) do
    "bg-background text-foreground shadow"
  end

  def active_tab(_tab_name, _current_tab) do
    ""
  end
end
