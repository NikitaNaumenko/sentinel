defmodule SentinelWeb.IntegrationLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.TelegramBot
  alias Sentinel.Integrations.Webhook

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    webhooks = Integrations.list_webhooks(socket.assigns.current_user.account)
    telegram_bots = Integrations.list_telegram_bots(socket.assigns.current_user.account)

    socket =
      socket
      |> assign(:page_title, dgettext("integrations", "Integrations"))
      |> assign(:enabled, webhooks ++ telegram_bots)

    {:ok, socket}
  end

  def integration(%{integration: %Webhook{}} = assigns) do
    ~H"""
    <.link
      class="flex hover:bg-secondary p-3 border rounded-lg gap-3"
      navigate={~p"/integrations/webhooks/#{@integration}/edit"}
    >
      <div class="flex items-center justify-center rounded-md border p-3">
        <img src={~p"/images/webhook.svg"} class="h-4 md:h-6" alt="Webhook" />
      </div>
      <div class="flex flex-col">
        <span>
          <%= @integration.name %>
        </span>
        <span>
          <%= dgettext("integrations", "Webhook") %>
        </span>
      </div>
    </.link>
    """
  end

  def integration(%{integration: %TelegramBot{}} = assigns) do
    ~H"""
    <.link
      class="flex hover:bg-secondary p-3 border rounded-lg gap-3"
      navigate={~p"/integrations/telegram_bots/#{@integration}/edit"}
    >
      <div class="flex items-center justify-center rounded-md border p-3">
        <img src={~p"/images/telegram.svg"} class="h-4 md:h-6" alt="telegram" />
      </div>
      <div class="flex flex-col">
        <span>
          <%= @integration.name %>
        </span>
        <span>
          <%= dgettext("integrations", "Telegram bot") %>
        </span>
      </div>
    </.link>
    """
  end
end
