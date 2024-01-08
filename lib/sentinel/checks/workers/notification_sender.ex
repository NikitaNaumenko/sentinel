defmodule Sentinel.Checks.Workers.NotificationSender do
  @moduledoc """
  Send notifications to users when something happened with monitor.
  """

  use Oban.Worker, queue: :notifications

  alias Sentinel.Checks
  alias Sentinel.Checks.Notifications.Email
  alias Sentinel.Mailer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    monitor = Checks.get_monitor!(id)

    # TODO: send only monitor users
    # TODO: send not only alerts
    monitor |> Email.alert(Sentinel.Repo.all(Sentinel.Accounts.User)) |> Mailer.deliver()
  end
end
