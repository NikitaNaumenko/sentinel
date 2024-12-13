defmodule SentinelWeb.IntegrationLive.NewWebhook do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Webhook.changeset(%Webhook{})

    socket =
      assign_form(socket, changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="d-flex mb-3">
        <div class="rounded-3 border p-2">
          <img src={~p"/images/webhook.svg"} class="h-4 md:h-6" alt="webhook" />
        </div>
        <div class="ms-2">
          <div class="fw-semibold">{dgettext("integrations", "New integration")}</div>
          <div>{dgettext("integrations", "Webhook")}</div>
        </div>
      </div>
      <.form for={@form} id="webhook-form" phx-change="validate" phx-submit="save">
        <.input
          label={dgettext("integrations", "Name")}
          field={@form[:name]}
          phx-debounce="200"
          placeholder="Support"
        />
        <.input
          field={@form[:endpoint]}
          label={dgettext("integrations", "Endpoint")}
          phx-debounce="200"
          placeholder="https://incident-happened.com/webhoooks"
        />

        <div class="">
          <.button phx-disable-with="Saving...">{dgettext("integrations", "Create")}</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl Phoenix.LiveView
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
