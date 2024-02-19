defmodule SentinelWeb.Components do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import SentinelWeb.Components.Badge
      import SentinelWeb.Components.Button
      import SentinelWeb.Components.Icon
      import SentinelWeb.Components.Label
      import SentinelWeb.Components.Switch
      import SentinelWeb.Components.Tabs
    end
  end
end
