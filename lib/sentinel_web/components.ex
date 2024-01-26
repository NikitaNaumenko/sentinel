defmodule SentinelWeb.Components do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import SentinelWeb.Components.Button
      import SentinelWeb.Components.Icon
    end
  end
end
