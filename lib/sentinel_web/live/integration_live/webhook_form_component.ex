defmodule SentinelWeb.IntegrationLive.WebhookFormComponent do
  @moduledoc false
  use SentinelWeb, :live_component

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage account records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="webhook-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:endpoint]} label={dgettext("integrations", "Endpoint")} type="text" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{webhook: webhook} = assigns, socket) do
    changeset = Webhook.changeset(webhook)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"webhook" => webhook_params}, socket) do
    changeset =
      socket.assigns.account
      |> Webhook.changeset(webhook_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"webhook" => webhook_params}, socket) do
    save_account(socket, socket.assigns.action, webhook_params)
  end

  defp save_account(socket, :edit, webhook_params) do
    case Integrations.update_webhook(socket.assigns.webhook, webhook_params) do
      {:ok, webhook} ->
        notify_parent({:saved, webhook})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("integrations", "Webhook updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_account(socket, :new, webhook_params) do
    case Integrations.create_webhook(webhook_params) do
      {:ok, webhook} ->
        notify_parent({:saved, webhook})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("webhook", "Webhook created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
