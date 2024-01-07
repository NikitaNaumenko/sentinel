defmodule SentinelWeb.HTMLHelpers do
  def hidden_tab_content?(tab, tab), do: false
  def hidden_tab_content?(_tab, _current_tab), do: true

  def active_tab(tab, tab) do
    "text-gray-900 bg-gray-100 dark:bg-gray-700 dark:text-white active"
  end

  def active_tab(_tab_name, _current_tab) do
    "bg-white hover:text-gray-700 hover:bg-gray-50  dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
  end
end
