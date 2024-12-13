defmodule Sentinel.StubTelegramClient do
  @moduledoc false
  def request(_token, _action, _opts) do
    Jason.encode(%{response: :ok})
  end
end
