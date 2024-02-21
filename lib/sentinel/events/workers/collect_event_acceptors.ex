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
    dbg("JOPAHUI")
    %{account: account} = Checks.get_monitor!(event.resource_id)

    dbg(account)
    account = Sentinel.Repo.preload(account, :users)
    # TODO: Escalation policy

    for user <- account.users do
      acceptor =
        Acceptor.create(%{
          recipient_id: user.id,
          event_id: event.id
        })

      %{id: acceptor.id}
      |> NotifyAcceptor.new()
      |> Oban.insert()
    end
  end
end
