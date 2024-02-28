defmodule Sentinel.Events.Workers.CollectEventAcceptors do
  @moduledoc """
  Send notifications to users when something happened with monitor.
  """

  use Oban.Worker, queue: :notifications

  alias Sentinel.Checks
  alias Sentinel.Events
  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  alias Sentinel.Events.Workers.NotifyAcceptor

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    %Event{type: event_type} = event = Events.get_event(id)

    process_event(event_type, event)
  end

  defp process_event(%MonitorDown{}, event) do
    %{account: account} = monitor = Checks.get_monitor!(event.resource_id)

    account = Sentinel.Repo.preload(account, :users)
    # TODO: Escalation policy

    monitor.notification_rule
    |> Map.from_struct()
    |> Map.take([:via_email, :via_slack, :via_webhook, :via_telegram])
    |> Enum.filter(fn {_name, value} -> value end)
    |> Enum.map(fn
      {:via_email, true} ->
        Enum.map(account.users, fn user ->
          %{
            recipient: %{id: user.id, type: to_string(user.__struct__)},
            event_id: event.id,
            recipient_type: "email"
          }
          |> Acceptor.create()
          |> Map.get(:id)
        end)

      {:via_webhook, true} ->
        %{
          recipient: %{
            id: monitor.notification_rule.webhook.id,
            type: to_string(monitor.notification_rule.webhook.__struct__)
          },
          event_id: event.id,
          recipient_type: "webhook"
        }
        |> Acceptor.create()
        |> Map.get(:id)
    end)
    |> Enum.map(&(&1 |> NotifyAcceptor.new() |> Oban.insert()))
  end
end
