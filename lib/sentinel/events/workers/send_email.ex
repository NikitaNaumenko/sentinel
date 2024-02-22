defmodule Sentinel.Events.Workers.SendEmail do
  @moduledoc false
  use Oban.Worker, queue: :notifications

  alias Sentinel.Events
  alias Sentinel.Events.UseCases.NotifyAcceptor

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{email_type: email_type} = args}) do
    Sentinel.Checks.Notifications.Email
    |> apply(email_type, [args])
    |> Sentinel.Mailer.deliver()
  end
end
