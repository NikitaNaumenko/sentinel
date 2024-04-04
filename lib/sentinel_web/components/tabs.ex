defmodule SentinelWeb.Components.Tabs do
  @moduledoc false

  use Phoenix.Component

  attr :current_tab, :string

  slot :tab do
    attr :id, :string, required: true
    attr :patch, :string
  end

  slot :tab_content do
    attr :id, :string, required: true
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
        aria-controls="content-overview"
        data-state="active"
        id={tab[:id]}
        class={[
          "ring-offset-background inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium transition-all focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
          active_tab(tab_name(tab[:id]), @current_tab)
        ]}
        tabindex="0"
        data-orientation="horizontal"
        patch={tab[:patch]}
      >
        <%= render_slot(tab) %>
      </.link>
    </div>
    <div
      :for={tab_content <- @tab_content}
      id={tab_content[:id]}
      class="pt-4"
      hidden={hidden_tab_content?(tab_content[:id], @current_tab)}
      aria-labelledby={"#{tab_content[:id]}-tab"}
    >
      <%= render_slot(tab_content) %>
    </div>
    """
  end

  def active_tab(tab, tab) do
    "bg-background text-foreground shadow"
  end

  def active_tab(_tab_name, _current_tab) do
    ""
  end

  defp tab_name(tab), do: tab |> String.split("-") |> hd()
  def hidden_tab_content?(tab, tab), do: false
  def hidden_tab_content?(_tab, _current_tab), do: true
end
