defmodule SentinelWeb.IntegrationLive.NewTelegramBot do
  @moduledoc false

  use SentinelWeb, :live_view

  alias Sentinel.Integrations
  alias Sentinel.Integrations.TelegramBot

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = TelegramBot.changeset(%TelegramBot{})

    {:ok, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center border-b p-5">
        <div class="flex items-center justify-center rounded-md border p-3">
          <img src={~p"/images/telegram.svg"} class="h-6 md:h-8" alt="Telegram" />
        </div>
        <div class="ml-1">
          <%= dgettext("integrations", "Telegram Bot") %>
        </div>
      </div>
      <.form for={@form} id="telegram-bot-form" phx-change="validate" phx-submit="save">
        <div class="flex items-center justify-between p-4">
          <div class="text-md mb-2 block max-w-xs">
            <%= dgettext("integrations", "Name") %>
          </div>
          <div class="min-w-[320px]">
            <.input field={@form[:name]} phx-debounce="200" placeholder="Support" />
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
            <.input field={@form[:token]} phx-debounce="200" placeholder="7223159943:AaG18cIB7gsU7Z4erJQ" />
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
      {:ok, _telegram_bot} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("integrations", "Telegram Bot created successfully"))
         |> push_navigate(to: ~p"/integrations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
