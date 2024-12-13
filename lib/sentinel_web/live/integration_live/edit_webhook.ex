defmodule SentinelWeb.IntegrationLive.EditWebhook do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    webhook = Integrations.get_webhook!(id, socket.assigns.current_account.id)
    changeset = Webhook.changeset(webhook)

    socket =
      socket
      |> assign(:webhook, webhook)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center border-b p-5">
        <div class="flex items-center justify-center rounded-md border p-3">
          <img src={~p"/images/webhook.svg"} class="h-4 md:h-6" alt="webhook" />
        </div>
        <div class="ml-1">
          {dgettext("integrations", "Webhook")}
        </div>
      </div>
      <.form for={@form} id="webhook-form" phx-change="validate" phx-submit="save">
        <div class="flex items-center justify-between p-4">
          <div class="text-md mb-2 block max-w-xs">
            {dgettext("integrations", "Name")}
          </div>
          <div class="min-w-[320px]">
            <.input field={@form[:name]} phx-debounce="200" />
          </div>
        </div>
        <div class="flex items-center justify-between p-4">
          <div class="text-md mb-2 block max-w-xs">
            {dgettext("integrations", "Endpoint")}
            <div class="text-sm text-gray-400">
              {dgettext(
                "integrations",
                "Use webhooks to notify external systems when something happens in sentinel."
              )}
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

  @impl Phoenix.LiveView
  def handle_event("validate", %{"webhook" => webhook_params}, socket) do
    changeset =
      socket.assigns.webhook
      |> Webhook.changeset(webhook_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"webhook" => webhook_params}, socket) do
    case Integrations.update_webhook(socket.assigns.webhook, webhook_params) do
      {:ok, _webhook} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("webhook", "Webhook created successfully"))
         |> push_navigate(to: ~p"/integrations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
