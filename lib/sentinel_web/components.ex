defmodule SentinelWeb.Components do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import SentinelWeb.Components.Badge
      import SentinelWeb.Components.Button
      import SentinelWeb.Components.Icon
      import SentinelWeb.Components.Input
      import SentinelWeb.Components.Label
      import SentinelWeb.Components.Switch
      import SentinelWeb.Components.Tabs
      import SentinelWeb.Components.Toast
    end
  end
end
