defmodule SentinelWeb.IntegrationLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_webhook, %{"id" => id}) do
    assign(socket, :webhook, Integrations.get_webhook!(id))
  end

  defp apply_action(socket, :new_webhook, _params) do
    assign(socket, :webhook, %Webhook{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:webhook, Integrations.get_account_webhook(socket.assigns.current_user.account_id))
    |> assign(:page_title, dgettext("integrations", "Integrations"))
  end

  @impl Phoenix.LiveView
  def handle_info({SentinelWeb.IntegrationLive.WebhookFormComponent, {:saved, _webhook}}, socket) do
    {:noreply, socket}
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   account = Accounts.get_account!(id)
  #   {:ok, _} = Accounts.delete_account(account)

  #   {:noreply, stream_delete(socket, :accounts, account)}
  # end
end
