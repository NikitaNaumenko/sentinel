defmodule Sentinel.Events.UseCases.SendTelegram do
  @moduledoc false
  alias Sentinel.Events.Acceptors.Telegram
  alias Sentinel.Integrations.Telegram.Client, as: TelegramClient
  alias Sentinel.Events.Fsm.TelegramFsm
  alias Sentinel.Repo

  require Logger

  def call(%{
        acceptor: acceptor,
        recipient: telegram,
        resource: resource,
        event_type: event_type,
        chat_id: chat_id
      }) do

    acceptor = Repo.preload(acceptor, [:event])

    with {:ok, _pid} <- create_telegram_acceptor(acceptor, telegram),
         :ok <- transition(acceptor.id, :send, %{}),
         {:ok, response} <- send_message(resource, event_type, chat_id),
         :ok <- transition(acceptor.id, :finish, %{}) do
      Logger.info(response)
      {:ok, :sent}
    else
      {:error, error} ->
        transition(acceptor.id, :fail, %{response: to_string(error)})
    end
  end

  def create_telegram_acceptor(acceptor, telegram) do
    attrs = %{
      acceptor_id: acceptor.id,
      telegram_id: telegram.id
    }

    Finitomata.start_fsm(TelegramFsm, acceptor.id, struct!(Telegram, attrs))
  end

  defp send_message(resource, event_type, chat_id) do
    message = build_message(event_type, resource)

    TelegramClient.request("sendMessage", chat_id: chat_id, text: message)
  end

  defp build_message(:monitor_down, resource) do
    """
    ❗️❗️❗️ Monitor #{resource.name} is down ❗️❗️❗️
    """
  end

  defp build_message(:monitor_up, resource) do
    """
    ✅✅✅Monitor #{resource.name} is up ✅✅✅
    """
  end

  defp transition(id, event, payload) do
    Finitomata.transition(id, {event, payload})
  end
end
