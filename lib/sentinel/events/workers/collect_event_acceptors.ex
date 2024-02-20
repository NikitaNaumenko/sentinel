defmodule Sentinel.Events.Workers.CollectEventAcceptors do
  @moduledoc """
  Send notifications to users when something happened with monitor.
  """

  use Oban.Worker, queue: :notifications

  # alias Sentinel.Checks
  alias Sentinel.Events
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  # alias Sentinel.Events.Workers.NotifyAcceptor
  # alias Sentinel.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    %Event{type: event_type} = event = Events.get_event(id)

    process_event(event_type, event)
  end

  defp process_event(%MonitorDown{}, _event) do
    %{account: account} =
      event.resource_id |> Checks.get_monitor() |> Repo.preload([:notification_rule, account: :users])

    # TODO: Escalation policy

    for user <- account.users do
      acceptor =
        Acceptor.create(%{
          recipient_id: user.id,
          recipient_type: to_string(user.__struct__),
          event_id: event.id
        })

      %{id: acceptor.id}
      |> NotifyAcceptor.new()
      |> Oban.insert()

      monitor.notification_rule
      |> Map.from_struct()
      |> Map.take([:via_email, :via_slack, :via_webhook, :via_telegram])
      |> Enum.filter(fn {_name, value} -> value end)
      |> Enum.map(fn {name, _value} ->
        acceptor = Acceptor.create(%{recipient_id: user.id, event_id: event.id, type: name})

        %{id: acceptor.id}
        |> NotifyAcceptor.new()
        |> Oban.insert()
      end)
    end
  end
end
