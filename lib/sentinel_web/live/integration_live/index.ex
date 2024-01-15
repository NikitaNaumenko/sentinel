defmodule SentinelWeb.IntegrationLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit Account")
  #   |> assign(:account, Accounts.get_account!(id))
  # end

  defp apply_action(socket, :new_webhook, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:webhook, %Webhook{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Accounts")
    |> assign(:account, nil)
  end

  @impl true
  def handle_info({SentinelWeb.AccountLive.FormComponent, {:saved, account}}, socket) do
    {:noreply, stream_insert(socket, :accounts, account)}
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   account = Accounts.get_account!(id)
  #   {:ok, _} = Accounts.delete_account(account)

  #   {:noreply, stream_delete(socket, :accounts, account)}
  # end
end
