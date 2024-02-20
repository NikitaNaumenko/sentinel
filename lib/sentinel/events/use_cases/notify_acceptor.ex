defmodule Sentinel.Events.UseCases.NotifyAcceptor do
  @moduledoc false
  alias Sentinel.Checks
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  alias Sentinel.Repo

  def call(acceptor) do
    acceptor = Repo.preload(acceptor, :event)
    process_acceptor(acceptor, acceptor.event)
  end

  def process_acceptor(_acceptor, %Event{type: %MonitorDown{}} = event) do
    monitor = event.resource_id |> Checks.get_monitor!() |> Repo.preload([:notification_rule])

    monitor.notification_rule
    |> Map.from_struct()
    |> Map.take([:via_email, :via_slack, :via_webhook, :via_telegram])
    |> Enum.filter(fn {_name, value} -> value end)
    |> Enum.map(fn {_name, _value} ->
      nil
      # acceptor = Acceptor.create(%{recipient_id: user.id, event_id: event.id, type: name})
      #
      # %{id: acceptor.id}
      # |> NotifyAcceptor.new()
      # |> Oban.insert()
    end)
  end
end
