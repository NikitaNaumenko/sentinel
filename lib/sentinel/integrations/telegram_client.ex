defmodule Sentinel.Integrations.Telegram do
  @moduledoc false
  @telegram_bot_token Application.compile_env!(:sentinel, :telegram_bot_token)

  def request(action, opts \\ []) do
    Telegram.Api.request(@telegram_bot_token, action, opts)
  end
end
