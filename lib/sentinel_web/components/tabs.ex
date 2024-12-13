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
    <ul class="nav nav-pills nav-fill">
      <li :for={tab <- @tab} class="nav-item">
        <.link
          class={["nav-link", active_tab(tab_name(tab[:id]), @current_tab)]}
          patch={tab[:patch]}
          aria-current="page"
          href="#"
        >
          {render_slot(tab)}
        </.link>
      </li>
    </ul>
    <div
      :for={tab_content <- @tab_content}
      id={tab_content[:id]}
      class="pt-4"
      hidden={hidden_tab_content?(tab_content[:id], @current_tab)}
      aria-labelledby={"#{tab_content[:id]}-tab"}
    >
      {render_slot(tab_content)}
    </div>
    """
  end

  def active_tab(tab, tab) do
    "active"
  end

  def active_tab(_tab_name, _current_tab) do
    ""
  end

  defp tab_name(tab), do: tab |> String.split("-") |> hd()
  def hidden_tab_content?(tab, tab), do: false
  def hidden_tab_content?(_tab, _current_tab), do: true
end
