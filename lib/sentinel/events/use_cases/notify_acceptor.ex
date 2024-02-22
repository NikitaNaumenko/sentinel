defmodule Sentinel.Events.UseCases.NotifyAcceptor do
  @moduledoc false
  alias Sentinel.Checks
  alias Sentinel.Events.Acceptor.Email
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  alias Sentinel.Repo

  def call(acceptor) do
    acceptor = Repo.preload(acceptor, :event)
    process_acceptor(acceptor, acceptor.event)
  end

  def process_acceptor(acceptor, %Event{type: %MonitorDown{}} = event) do
    monitor = event.resource_id |> Checks.get_monitor!() |> Repo.preload([:notification_rule])

    monitor.notification_rule
    |> Map.from_struct()
    |> Map.take([:via_email, :via_slack, :via_webhook, :via_telegram])
    |> Enum.filter(fn {_name, value} -> value end)
    |> Enum.map(fn
      {:via_email, _value} ->
        dbg(:email_sent)
        :email_sent

      # SendEmail.new(%{acceptor_id: acceptor.id, recipient_id: acceptor.recipient_id})
      {:via_webhook, _} ->
        dbg(:webhook_sent)
        :webhook_sent
    end)
  end
end
