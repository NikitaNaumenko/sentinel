defmodule Sentinel.Integrations.Telegram.Client do
  @moduledoc false
  @type request_result :: {:ok, term()} | {:error, term()}
  @type parameter_name :: atom() | String.t()
  @type parameter_value ::
          integer()
          | float()
          | String.t()
          | boolean()
          | {:json, json_serialized_object :: term()}
          | {:file, path :: Path.t()}
          | {:file_content, content :: iodata(), filename :: String.t()}
  @type parameters :: [{parameter_name(), parameter_value()}]

  @telegram_bot_token Application.compile_env!(:sentinel, :telegram_bot_token)

  @callback request(Telegram.Types.method(), parameters()) :: request_result()
  def request(action, opts \\ []) do
    impl().request(@telegram_bot_token, action, opts)
  end

  defp impl do
    Application.get_env(:sentinel, :telegram_client, Telegram.Api)
  end
end
