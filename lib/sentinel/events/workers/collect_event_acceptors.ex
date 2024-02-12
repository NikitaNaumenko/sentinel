defmodule Sentinel.Events.Workers.CollectEventAcceptors do
  @moduledoc """
  Send notifications to users when something happened with monitor.
  """

  use Oban.Worker, queue: :notifications

  alias Sentinel.Events.Event
  alias Sentinel.Events
  alias Sentinel.Checks
  alias Sentinel.Checks.Notifications.Email
  alias Sentinel.Mailer
  alias Sentinel.Events.EventTypes.MonitorDown
  import Ecto.Query
  alias Sentinel.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    %Event{type: event_type} = event = Events.get_event(id)

    process_event(event_type, event)
  end

  defp process_event(%MonitorDown{}, event) do
    %{monitor: %{account: account} = monitor} = check = Checks.get_check(event.resource_id) |> Repo.preload(monitor: [:notification_rule, account: :users])
    # TODO: Escalation policy

    for user <- account.users do
      monitor.notification_rule |> Map.from_struct() |> Map.take([:via_email, :via_slack, :via_webhook, :via_telegram]) |> Enum.filter(fn {_name, value} -> value end) |> Enum.map(fn {name, _value} ->
        Acceptor.create(%{recipient_id: user.id, event_id: event.id, type: name})
      end)
    end
  end
end
