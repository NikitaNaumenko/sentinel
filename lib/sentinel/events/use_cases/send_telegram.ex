defmodule Sentinel.Events.UseCases.SendTelegram do
  @moduledoc false
  alias Sentinel.Events.Acceptors.TelegramBot
  alias Sentinel.Events.Fsm.TelegramBotFsm
  alias Sentinel.Repo

  require Logger

  def call(%{
        acceptor: acceptor,
        recipient: telegram_bot,
        resource: resource,
        event_type: event_type,
        chat_id: chat_id
      }) do
    acceptor = Repo.preload(acceptor, [:event])

    with {:ok, _pid} <- create_telegram_acceptor(acceptor, telegram_bot),
         :ok <- transition(acceptor.id, :send, %{}),
         {:ok, response} <- send_message(telegram_bot, resource, event_type, chat_id),
         :ok <- transition(acceptor.id, :finish, %{}) do
      Logger.info(response)
      {:ok, :sent}
    else
      {:error, error} ->
        transition(acceptor.id, :fail, %{response: to_string(error)})
    end
  end

  def create_telegram_acceptor(acceptor, telegram_bot) do
    attrs = %{
      acceptor_id: acceptor.id,
      telegram_bot_id: telegram_bot.id
    }

    Finitomata.start_fsm(TelegramBotFsm, acceptor.id, struct!(TelegramBot, attrs))
  end

  defp send_message(telegram_bot, resource, event_type, chat_id) do
    message = build_message(event_type, resource)
    Telegram.Api.request(telegram_bot.token, "sendMessage", chat_id: chat_id, text: message)
  end

  defp build_message(:monitor_down, resource) do
    """
    ❗️❗️❗️ Monitor #{resource.name} is down ❗️❗️❗️
    """
  end

  defp transition(id, event, payload) do
    Finitomata.transition(id, {event, payload})
  end
end
