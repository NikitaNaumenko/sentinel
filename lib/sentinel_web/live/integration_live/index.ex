defmodule SentinelWeb.IntegrationLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Telegram
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Integrations.SlackWebhook

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    webhooks = Integrations.list_webhooks(socket.assigns.current_user.account)
    telegrams = Integrations.list_telegrams(socket.assigns.current_user.account)
    slack_webhooks = Integrations.list_slack_webhooks(socket.assigns.current_user.account)

    socket =
      socket
      |> assign(:page_title, dgettext("integrations", "Integrations"))
      |> assign(:enabled, webhooks ++ telegrams ++ slack_webhooks)

    {:ok, socket}
  end

  def integration(%{integration: %Webhook{}} = assigns) do
    ~H"""
    <.link class="card" navigate={~p"/integrations/webhooks/#{@integration}/edit"}>
      <div class="card-body d-flex">
        <div class="rounded-3 border p-2">
          <img src={~p"/images/webhook.svg"} class="h-4 md:h-6" alt="Webhook" />
        </div>
        <div class="d-flex flex-column ms-2">
          <span class="fw-semibold">
            {@integration.name}
          </span>
          <span>
            {dgettext("integrations", "Webhook")}
          </span>
        </div>
      </div>
    </.link>
    """
  end

  def integration(%{integration: %Telegram{}} = assigns) do
    ~H"""
    <.link class="card" navigate={~p"/integrations/telegrams/#{@integration}/edit"}>
      <div class="card-body d-flex">
        <div class="rounded-3 border p-2">
          <img src={~p"/images/telegram.svg"} class="h-4 md:h-6" alt="telegram" />
        </div>
        <div class="d-flex flex-column ms-2">
          <span class="fw-semibold">
            {@integration.name}
          </span>
          <span>
            {dgettext("integrations", "Telegram bot")}
          </span>
        </div>
      </div>
    </.link>
    """
  end

  def integration(%{integration: %SlackWebhook{}} = assigns) do
    ~H"""
    <.link class="card" navigate={~p"/integrations/slack_webhooks/#{@integration}/edit"}>
      <div class="card-body d-flex">
        <div class="rounded-3 border p-2">
          <img src={~p"/images/slack.svg"} class="h-4 md:h-6" alt="slack" />
        </div>
        <div class="d-flex flex-column ms-2">
          <span class="fw-semibold">
            {@integration.name}
          </span>
          <span>
            {dgettext("integrations", "Slack webhook")}
          </span>
        </div>
      </div>
    </.link>
    """
  end
end
