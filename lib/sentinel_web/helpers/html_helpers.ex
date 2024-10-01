defmodule SentinelWeb.HTMLHelpers do
  @moduledoc false
  def hidden_tab_content?(tab, tab), do: false
  def hidden_tab_content?(_tab, _current_tab), do: true

  def active_tab(tab, tab) do
    "active"
  end

  def active_tab(_tab_name, _current_tab) do
    ""
  end
end
