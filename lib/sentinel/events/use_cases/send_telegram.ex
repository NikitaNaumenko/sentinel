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
         {:ok, response} <- send_message(user, resource, event_type),
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

  defp send_message(telegram_bot, resource, event_type) do
    Sentinel.Events.Notifications.Email
    |> apply(event_type, [build_args(event_type, resource, telegram_bot)])
    |> Sentinel.Mailer.deliver()
  end

  defp build_args(:monitor_down, resource, user) do
    %{monitor: resource, user: user}
  end

  defp transition(id, event, payload) do
    Finitomata.transition(id, {event, payload})
  end
end
