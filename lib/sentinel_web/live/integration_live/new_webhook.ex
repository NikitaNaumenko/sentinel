defmodule SentinelWeb.IntegrationLive.NewWebhook do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  def mount(_params, _session, socket) do
    changeset = Webhook.changeset(%Webhook{})

    socket =
      assign_form(socket, changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="border-b p-5">
        <span class="icon-webhook"></span>
        <%= dgettext("integrations", "Webhook") %>
      </div>
      <.form for={@form} id="webhook-form" phx-change="validate" phx-submit="save">
        <div class="flex items-center justify-between p-4">
          <div class="text-md mb-2 block max-w-xs">
            <%= dgettext("integrations", "Name") %>
          </div>
          <div class="min-w-[320px]">
            <.input field={@form[:name]} phx-debounce="200" />
          </div>
        </div>
        <div class="flex items-center justify-between p-4">
          <div class="text-md mb-2 block max-w-xs">
            <%= dgettext("integrations", "Endpoint") %>
            <div class="text-sm text-gray-400">
              <%= dgettext(
                "integrations",
                "Use webhooks to notify external systems when something happens in sentinel."
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

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"webhook" => webhook_params}, socket) do
    changeset =
      %Webhook{}
      |> Webhook.changeset(Map.put(webhook_params, "account_id", socket.assigns.current_user.account_id))
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"webhook" => webhook_params}, socket) do
    case Integrations.create_webhook(
           Map.put(webhook_params, "account_id", socket.assigns.current_user.account_id)
         ) do
      {:ok, webhook} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("webhook", "Webhook created successfully"))
         |> push_navigate(to: ~p"/integrations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
