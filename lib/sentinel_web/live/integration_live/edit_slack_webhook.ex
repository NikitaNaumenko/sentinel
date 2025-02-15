defmodule SentinelWeb.IntegrationLive.EditSlackWebhook do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.SlackWebhook

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    slack_webhook = Integrations.get_slack_webhook!(id, socket.assigns.current_account.id)
    changeset = SlackWebhook.changeset(slack_webhook, %{})

    socket =
      socket
      |> assign(:slack_webhook, slack_webhook)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="slack-webhook-form" phx-change="validate" phx-submit="save">
      <:title>
        <div class="d-flex">
          <div class="flex items-center border-b p-5">
            <div class="flex items-center justify-center rounded-md border p-3">
              <img src={~p"/images/slack.svg"} class="h-6 md:h-8" alt="Slack" />
            </div>
            <div class="ml-1">
              {dgettext("integrations", "Slack Webhook")}
            </div>
          </div>
        </div>
      </:title>
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
          {dgettext("integrations", "Webhook URL")}
          <div class="text-sm text-gray-400">
            {dgettext(
              "integrations",
              "Use Slack webhook to notify your channels when something happens in sentinel."
            )}
          </div>
        </div>
        <div class="min-w-[320px]">
          <.input field={@form[:url]} phx-debounce="200" />
        </div>
      </div>

      <:actions>
        <div class="d-flex">
          <.link class="btn btn-link" navigate={~p"/integrations"}>Back</.link>
          <.button class="ms-auto" phx-disable-with="Saving...">{dgettext("integrations", "Save")}</.button>
        </div>
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"slack_webhook" => params}, socket) do
    changeset =
      socket.assigns.slack_webhook
      |> SlackWebhook.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"slack_webhook" => params}, socket) do
    case Integrations.update_slack_webhook(socket.assigns.slack_webhook, params) do
      {:ok, _slack_webhook} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("integrations", "Slack webhook updated successfully"))
         |> push_navigate(to: ~p"/integrations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
