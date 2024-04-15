defmodule Sentinel.Events.UseCases.SendEmail do
  @moduledoc false
  alias Sentinel.Events.Acceptors.Email
  alias Sentinel.Events.Fsm.EmailFsm
  alias Sentinel.Repo

  require Logger

  def call(%{acceptor: acceptor, recipient: user, resource: resource, event_type: event_type}) do
    acceptor = Repo.preload(acceptor, [:event])

    with {:ok, _pid} <- create_email_acceptor(acceptor, user),
         :ok <- transition(acceptor.id, :send, %{}),
         {:ok, response} <- send_email(acceptor, user, resource, event_type),
         :ok <- transition(acceptor.id, :finish, %{}) do
      Logger.info(response)
      {:ok, :sent}
    else
      {:error, error} ->
        transition(acceptor.id, :fail, %{response: to_string(error)})
    end
  end

  def create_email_acceptor(acceptor, user) do
    attrs = %{
      acceptor_id: acceptor.id,
      user_id: user.id
    }

    Finitomata.start_fsm(EmailFsm, acceptor.id, struct!(Email, attrs))
  end

  defp send_email(acceptor, user, resource, event_type) do
    Sentinel.Events.Notifications.Email
    |> apply(event_type, [build_args(acceptor, event_type, resource, user)])
    |> Sentinel.Mailer.deliver()
  end

  defp build_args(_acceptor, :monitor_down, resource, user) do
    %{monitor: resource, user: user}
  end

  defp build_args(_acceptor, :monitor_up, resource, user) do
    %{monitor: resource, user: user}
  end

  defp build_args(acceptor, :teammate_created, resource, _user) do
    %{user: resource, token: acceptor.event.payload["token"]}
  end

  defp transition(id, event, payload) do
    Finitomata.transition(id, {event, payload})
  end
end
