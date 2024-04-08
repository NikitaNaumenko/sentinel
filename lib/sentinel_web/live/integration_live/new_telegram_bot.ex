defmodule SentinelWeb.IntegrationLive.NewTelegramBot do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.TelegramBot

  def mount(_params, _session, socket) do
    changeset = TelegramBot.changeset(%TelegramBot{})

    socket =
      assign_form(socket, changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="border-b p-5">
        <.icon name="simple-telegram" class="mr-2 inline-block h-6 w-6" />
        <%= dgettext("integrations", "Telegram Bot") %>
      </div>
      <.form for={@form} id="telegram-bot-form" phx-change="validate" phx-submit="save">
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
            <%= dgettext("integrations", "Telegram bot Token") %>
            <div class="text-sm text-gray-400">
              <%= dgettext(
                "integrations",
                "Use telegram bots to notify external systems when something happens in sentinel."
              ) %>
            </div>
          </div>
          <div class="min-w-[320px]">
            <.input field={@form[:token]} phx-debounce="200" />
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
  def handle_event("validate", %{"telegram_bot" => params}, socket) do
    changeset =
      %TelegramBot{}
      |> TelegramBot.changeset(Map.put(params, "account_id", socket.assigns.current_user.account_id))
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"telegram_bot" => params}, socket) do
    case Integrations.create_telegram_bot(
           Map.put(params, "account_id", socket.assigns.current_user.account_id)
         ) do
      {:ok, webhook} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("integrations", "Telegram Bot created successfully"))
         |> push_navigate(to: ~p"/integrations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
