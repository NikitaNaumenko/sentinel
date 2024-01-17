defmodule SentinelWeb.Carbon do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import Sentinel.Carbon.Button
    end
  end
end
