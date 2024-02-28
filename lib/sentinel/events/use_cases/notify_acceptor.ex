defmodule Sentinel.Events.UseCases.NotifyAcceptor do
  @moduledoc false
  alias Sentinel.Checks
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  alias Sentinel.Events.UseCases.SendEmail
  alias Sentinel.Events.UseCases.SendWebhook
  alias Sentinel.Repo

  def call(acceptor) do
    acceptor = Repo.preload(acceptor, [:event])
    process_acceptor(acceptor, acceptor.event)
  end

  def process_acceptor(acceptor, %Event{type: %MonitorDown{}} = event) do
    monitor = event.resource_id |> Checks.get_monitor!() |> Repo.preload([:notification_rule])

    monitor.notification_rule
    |> dbg()
    |> Map.from_struct()
    |> Map.take([:via_email, :via_slack, :via_webhook, :via_telegram])
    |> Enum.filter(fn {_name, value} -> value end)
    |> Enum.map(fn
      {:via_email, true} ->
        SendEmail.call(%{
          acceptor: acceptor,
          recipient: acceptor.recipient,
          event_type: :monitor_down,
          resource: monitor
        })

      {:via_webhook, true} ->
        SendWebhook.call(%{
          acceptor: acceptor,
          recipient: acceptor.recipient,
          event_type: :monitor_down,
          resource: monitor
        })
    end)
  end
end
