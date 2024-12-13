defmodule Sentinel.Events.UseCases.NotifyAcceptor do
  @moduledoc """
  The `NotifyAcceptor` module is part of the Sentinel event notification system. It is responsible for processing notifications for acceptors based on the type of event that has occurred, specifically focusing on `MonitorDown` events. An acceptor can be an individual, a service, or a system component that has previously expressed interest in being notified about such events.

  ## Functionality

  This module provides functionality to notify acceptors when a monitor associated with them goes down. It supports different types of notification mechanisms, including email and webhook, based on the acceptor's preference.

  ### The `call/1` Function

  - `call(acceptor_id)`: Takes an `acceptor_id` as an argument, retrieves the corresponding acceptor and its associated event from the database, and then processes the notification based on the acceptor's `recipient_type` and the event type.

  ## Notification Process

  The notification process varies depending on the `recipient_type` of the acceptor and the type of event:

  - **Email Notification**: If the `recipient_type` is `"email"` and the event type is `"MonitorDown"`, an email is sent to the recipient with the details of the event. This ensures that the acceptor is promptly informed about the event through their preferred communication channel.

  - **Webhook Notification**: If the `recipient_type` is `"webhook"` and the event type is `"MonitorDown"`, a webhook is dispatched to the recipient with the details of the event. This allows for automated processing and handling of the event by the acceptor's systems.

  ## Usage

  The `NotifyAcceptor` module can be invoked by other parts of the system that need to notify acceptors about events. It abstracts the complexity of determining the appropriate notification mechanism based on the acceptor's preferences and the nature of the event.

  ## Example

      iex> acceptor_id = "some-acceptor-id"
      iex> Sentinel.Events.UseCases.NotifyAcceptor.call(acceptor_id)
      :ok

  This example demonstrates how to invoke the `NotifyAcceptor` module to notify an acceptor about a `MonitorDown` event. The function returns `:ok` upon successful execution.
  """
  alias Sentinel.Events
  alias Sentinel.Events.Acceptor
  alias Sentinel.Events.Event
  alias Sentinel.Events.EventTypes.MonitorDown
  alias Sentinel.Events.EventTypes.MonitorUp
  alias Sentinel.Events.EventTypes.TeammateCreated
  alias Sentinel.Events.UseCases.SendEmail
  alias Sentinel.Events.UseCases.SendTelegram
  alias Sentinel.Events.UseCases.SendWebhook
  alias Sentinel.Monitors
  alias Sentinel.Repo
  alias Sentinel.Teammates

  def call(acceptor_id) do
    acceptor = acceptor_id |> Events.get_acceptor() |> Repo.preload([:event])
    process_acceptor(acceptor, acceptor.event)
  end

  defp process_acceptor(%Acceptor{recipient_type: "email"} = acceptor, %Event{type: %MonitorDown{}} = event) do
    monitor = Monitors.get_monitor!(event.resource_id)

    SendEmail.call(%{
      acceptor: acceptor,
      recipient: acceptor.recipient,
      event_type: :monitor_down,
      resource: monitor
    })
  end

  defp process_acceptor(%Acceptor{recipient_type: "webhook"} = acceptor, %Event{type: %MonitorDown{}} = event) do
    monitor = Monitors.get_monitor!(event.resource_id)

    SendWebhook.call(%{
      acceptor: acceptor,
      recipient: acceptor.recipient,
      event_type: :monitor_down,
      resource: monitor
    })
  end

  defp process_acceptor(
         %Acceptor{recipient_type: "telegram"} = acceptor,
         %Event{type: %MonitorDown{}} = event
       ) do
    monitor =
      event.resource_id
      |> Monitors.get_monitor!()
      |> Repo.preload(escalation_policy: [escalation_steps: :escalation_alerts])

    Enum.each(monitor.escalation_policy.escalation_steps, fn step ->
      # TODO Дичь
      Enum.each(step.escalation_alerts, fn alert ->
        SendTelegram.call(%{
          acceptor: acceptor,
          recipient: acceptor.recipient,
          event_type: :monitor_down,
          resource: monitor,
          chat_id: "-4760403358"
          # chat_id: alert.user_id
        })
      end)
    end)
  end

  defp process_acceptor(%Acceptor{recipient_type: "email"} = acceptor, %Event{type: %MonitorUp{}} = event) do
    monitor = Monitors.get_monitor!(event.resource_id)

    SendEmail.call(%{
      acceptor: acceptor,
      recipient: acceptor.recipient,
      event_type: :monitor_up,
      resource: monitor
    })
  end

  defp process_acceptor(%Acceptor{recipient_type: "webhook"} = acceptor, %Event{type: %MonitorUp{}} = event) do
    monitor = Monitors.get_monitor!(event.resource_id)

    SendWebhook.call(%{
      acceptor: acceptor,
      recipient: acceptor.recipient,
      event_type: :monitor_up,
      resource: monitor
    })
  end

  defp process_acceptor(%Acceptor{recipient_type: "telegram"} = acceptor, %Event{type: %MonitorUp{}} = event) do
    monitor =
      event.resource_id
      |> Monitors.get_monitor!()
      |> Repo.preload(escalation_policy: [escalation_steps: :escalation_alerts])

    Enum.each(monitor.escalation_policy.escalation_steps, fn step ->
      # TODO Дичь
      Enum.each(step.escalation_alerts, fn alert ->
        SendTelegram.call(%{
          acceptor: acceptor,
          recipient: acceptor.recipient,
          event_type: :monitor_up,
          resource: monitor,
          chat_id: "-4760403358"
          # chat_id: alert.user_id
        })
      end)
    end)
  end

  defp process_acceptor(
         %Acceptor{recipient_type: "email"} = acceptor,
         %Event{type: %TeammateCreated{}} = event
       ) do
    user = Teammates.get_teammate!(event.resource_id)

    SendEmail.call(%{
      acceptor: acceptor,
      recipient: acceptor.recipient,
      event_type: :teammate_created,
      resource: user
    })
  end

  defp process_acceptor(_acceptor, _event) do
    {:error, "Unsupported acceptor type or event"}
  end
end
