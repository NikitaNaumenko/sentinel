defmodule Sentinel.StubTelegramClient do
  def request(_token, _action, _opts) do
    Jason.encode(%{response: :ok})
  end
end
