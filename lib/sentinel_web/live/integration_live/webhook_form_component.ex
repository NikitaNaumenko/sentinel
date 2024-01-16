defmodule SentinelWeb.IntegrationLive.WebhookFormComponent do
  @moduledoc false
  use SentinelWeb, :live_component

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="border-b p-5">
        <img src={~p"/images/webhook_icon.svg"} class="me-3 inline h-6 sm:h-7" alt="Webhook icon" />
        <%= dgettext("integrations", "Webhook") %>
      </div>
      <.form :let={f} for={@form} id="webhook-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="flex items-center justify-between border-b p-4">
          <div class="text-md mb-2 block max-w-xs">
            <%= dgettext("integrations", "Endpoint") %>
            <div class="text-sm text-gray-400">
              <%= dgettext(
                "integrations",
                "Use webhooks to notify external systems when something happens in hyperping.io. Read how to setup"
              ) %>
            </div>
          </div>
          <div class="min-w-[320px]">
            <.input field={@form[:endpoint]} phx-debounce="200" />
          </div>
        </div>

        <div class="flex justify-end p-4">
          <%!-- <.button class="mr-3">Cancel</.button> --%>
          <.button phx-disable-with="Saving...">Save</.button>
        </div>
      </.form>
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
      socket.assigns.webhook
      |> Webhook.changeset(Map.put(webhook_params, "account_id", socket.assigns.account_id))
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"webhook" => webhook_params}, socket) do
    save_webhook(socket, socket.assigns.action, webhook_params)
  end

  defp save_webhook(socket, :edit, webhook_params) do
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

  defp save_webhook(socket, :new_webhook, webhook_params) do
    case Integrations.create_webhook(Map.put(webhook_params, "account_id", socket.assigns.account_id)) do
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
