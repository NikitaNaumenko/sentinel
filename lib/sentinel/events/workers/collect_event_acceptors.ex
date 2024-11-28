defmodule Sentinel.Events.Workers.CollectEventAcceptors do
  @moduledoc """
  Send notifications to users when something happened with monitor.
  """

  use Oban.Worker, queue: :notifications

  alias Sentinel.Escalations
  alias Sentinel.Events
  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Event
  alias Sentinel.Events.Workers.NotifyAcceptor
  alias Sentinel.Monitors
  alias Sentinel.Teammates

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    %Event{type: event_type} = event = Events.get_event(id)

    process_event(event_type.type, event)
  end

  defp process_event(event_type, event) when event_type in ["monitor_down", "monitor_up"] do
    %{account: account} = monitor = Monitors.get_monitor!(event.resource_id)

    account = Sentinel.Repo.preload(account, :users)

    dbg(monitor)
    escalation_policy = Escalations.get_escalation_policy!(monitor.escalation_policy_id)

    escalation_policy.escalation_steps
    |> Stream.flat_map(fn step ->
      Enum.map(step.escalation_alerts, fn alert -> process_alert(alert, event, account) end)
    end)
    |> Enum.each(fn
      ids when is_list(ids) ->
        Enum.each(ids, &(%{id: &1} |> NotifyAcceptor.new() |> Oban.insert()))

      id ->
        %{id: id} |> NotifyAcceptor.new() |> Oban.insert()
    end)

    :ok
  end

  defp process_event("teammate_created", event) do
    user = Teammates.get_teammate!(event.resource_id)

    %{
      recipient: %{id: user.id, type: to_string(Sentinel.Accounts.User)},
      event_id: event.id,
      recipient_type: "email"
    }
    |> Acceptor.create()
    |> Map.take([:id])
    |> NotifyAcceptor.new()
    |> Oban.insert()
  end

  defp process_alert(%{alert_type: :email, user_id: nil} = _alert, event_id, account) do
    Enum.map(account.users, fn user ->
      %{
        recipient: %{id: user.id, type: to_string(Sentinel.Accounts.User)},
        event_id: event_id,
        recipient_type: "email"
      }
      |> Acceptor.create()
      |> Map.get(:id)
    end)
  end

  defp process_alert(%{alert_type: :email, user_id: user_id} = _alert, event_id, _account)
       when not is_nil(user_id) do
    %{recipient: %{id: user_id, type: "Sentinel.Accounts.User"}, event_id: event_id, recipient_type: "email"}
    |> Acceptor.create()
    |> Map.get(:id)
  end

  defp process_alert(%{alert_type: :telegram} = alert, event_id, _account) do
    %{
      recipient: %{
        id: alert.telegram_id,
        type: to_string(Sentinel.Integrations.Telegram)
      },
      event_id: event_id,
      recipient_type: "telegram"
    }
    |> Acceptor.create()
    |> Map.get(:id)
  end

  defp process_alert(%{alert_type: :webhook} = alert, event_id, _account) do
    %{
      recipient: %{
        id: alert.webhook.id,
        type: to_string(Sentinel.Integrations.Webhook)
      },
      event_id: event_id,
      recipient_type: "webhook"
    }
    |> Acceptor.create()
    |> Map.get(:id)
  end

  defp process_alert(_alert, _event_id, _account) do
    raise RuntimeError, "Undefined alert error"
  end
end
