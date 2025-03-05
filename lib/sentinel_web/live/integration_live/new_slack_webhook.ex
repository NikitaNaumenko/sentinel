defmodule SentinelWeb.IntegrationLive.NewSlackWebhook do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.SlackWebhook

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = SlackWebhook.changeset(%SlackWebhook{}, %{})

    {:ok, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="slack-webhook-form" phx-change="validate" phx-submit="save">
      <:title>
        <div class="d-flex">
          <div class="rounded-3 border p-2">
            <img src={~p"/images/slack.svg"} class="h-4 md:h-6" alt="Slack" />
          </div>
          <div class="ms-2">
            <div class="fw-semibold">{dgettext("integrations", "New integration")}</div>
            <div>{dgettext("integrations", "Slack Webhook")}</div>
          </div>
        </div>
      </:title>
      <.input
        field={@form[:name]}
        label={dgettext("integrations", "Name")}
        phx-debounce="200"
        placeholder="Notifications"
      />
      <div class="text-md mb-2 block max-w-xs">
        {dgettext("integrations", "Webhook URL")}
        <div class="text-body-secondary text-sm">
          {dgettext(
            "integrations",
            "Use Slack webhook to notify your channels when something happens in sentinel."
          )}
        </div>
      </div>
      <.input field={@form[:url]} phx-debounce="200" placeholder="https://hooks.slack.com/services/xxx/yyy/zzz" />
      <:actions>
        <div class="d-flex">
          <.link class="btn btn-link" navigate={~p"/integrations"}>Back</.link>
          <.button class="ms-auto" phx-disable-with="Saving...">{dgettext("integrations", "Create")}</.button>
        </div>
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"slack_webhook" => params}, socket) do
    changeset =
      %SlackWebhook{}
      |> SlackWebhook.changeset(Map.put(params, "account_id", socket.assigns.current_user.account_id))
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"slack_webhook" => params}, socket) do
    case Integrations.create_slack_webhook(
           Map.put(params, "account_id", socket.assigns.current_user.account_id)
         ) do
      {:ok, _slack_webhook} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("integrations", "Slack webhook created successfully"))
         |> push_navigate(to: ~p"/integrations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
