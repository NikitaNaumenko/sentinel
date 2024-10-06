defmodule SentinelWeb.MonitorLive.Components.Notifications do
  @moduledoc false
  use SentinelWeb, :live_component

  alias Sentinel.Integrations
  alias Sentinel.Monitors
  alias Sentinel.Monitors.NotificationRule

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <div class="fw-semibold">
        <%= dgettext("monitors", "Notification Rules") %>
      </div>

      <div class="card cad-md">
        <div class="card-body">
          <div class="vstack gap-1">
            <span class="fw-medium">
              <%= dgettext("monitors", "Team level notifications") %>
            </span>
            <span>
              You will receive notifications for the enabled channels that are configured. To send emails & SMS to specific teammates, please configure an escalation policy.
            </span>
          </div>
          <div class="mt-2 flex gap-1">
            <div class="mr-5">
              <label
                class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                phx-target={@myself}
                phx-click={
                  JS.push("toggle-via",
                    value: %{id: @notification_rule.id, attr: "via_email", value: @notification_rule.via_email}
                  )
                }
              >
                <input
                  type="checkbox"
                  id="email"
                  name="via_email"
                  value="true"
                  checked={@notification_rule.via_email}
                  class="border-primary text-primary rounded focus:ring-0"
                />
                <%= dgettext("monitors", "Email") %>
              </label>
            </div>
          </div>
          <div class="mt-5 flex w-full items-center justify-between space-x-4">
            <%!-- <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
              <span>
                <%= dgettext("monitors", "Webhook") %>
              </span>
              <span class="text-muted-foreground text-sm font-normal leading-snug">
                <%= if Enum.any?(@webhooks) do %>
                  <%= dgettext("monitors", "Choose webhook from created earlier") %>
                <% else %>
                  <%= dgettext("monitors", "To choose webhook you have to create it before") %>
                <% end %>
              </span>
            </label>
            <div>
              <.form :if={Enum.any?(@webhooks)} for={@form} phx-change="update-webhook" phx-target={@myself}>
                <.input
                  type="select"
                  options={collection_for_select(@webhooks, {:id, :name}, empty: {gettext("Not selected"), nil})}
                  field={@form[:webhook_id]}
                  class="min-w-[360px]"
                />
              </.form>
            </div> --%>
          </div>
          <div class="mt-5 flex w-full items-center justify-between space-x-4">
            <%!-- <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
              <span>
                <%= dgettext("monitors", "Telegram") %>
              </span>
              <span class="text-muted-foreground text-sm font-normal leading-snug">
                <%= if Enum.any?(@telegram_bots) do %>
                  <%= dgettext(
                    "monitors",
                    "Choose telegram bot from created earlier, invite bot and then run sync"
                  ) %>
                <% else %>
                  <%= dgettext("monitors", "To choose telegram bot you have to create it before") %>
                <% end %>
              </span>
              <div :if={@telegram_bot_info}>
                <.bot_info :for={bot_info <- @telegram_bot_info} telegram_bot_info={bot_info} />
              </div>
            </label> --%>
            <%!-- <div>
              <div :if={Enum.any?(@telegram_bots)}>
                <.form for={@form} phx-change="update-telegram" phx-target={@myself} class="flex flex-col gap-2">
                  <.input
                    type="select"
                    options={
                      collection_for_select(@telegram_bots, {:id, :name}, empty: {gettext("Not selected"), nil})
                    }
                    field={@form[:telegram_bot_id]}
                  />
                  <.input
                    field={@form[:telegram_chat_id]}
                    class="mt-2"
                    placeholder={dgettext("monitors", "Chat id: -10102043")}
                  />
                </.form>
                <.button phx-click="sync-telegram" phx-target={@myself} class="mt-2">
                  <%= dgettext("monitors", "Fetch chat info") %>
                </.button>
              </div>
            </div> --%>
          </div>
          <%!-- <div class="mt-5 flex w-full items-center justify-between space-x-4">
            <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
              <span>
                <%= dgettext("monitors", "Activate monitoring") %>
              </span>
              <span class="text-muted-foreground text-sm font-normal leading-snug">
                When unchecked, Sentinel will stop pinging this monitor.
              </span>
            </label>
            <div>
              <.form for={@form}>
                <.input type="select" options={@resend_interval_options} field={@form[:resend_interval]} />
              </.form>
            </div>
          </div>
          <div class="mt-5 flex w-full items-center justify-between space-x-4">
            <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
              <span>
                <%= dgettext("monitors", "Activate monitoring") %>
              </span>
              <span class="text-muted-foreground text-sm font-normal leading-snug">
                When unchecked, Sentinel will stop pinging this monitor.
              </span>
            </label>
            <div>
              <.form for={@form}>
                <.input type="select" options={@timeout_options} field={@form[:timeout]} />
              </.form>
            </div>
          </div> --%>
        </div>
      </div>

      <div class="fw-semibold">
        <%= dgettext("monitors", "SSL monitoring") %>
      </div>

      <div class="card card-md">
        <div class="card-body">
          <label class="flex flex-col font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
            <span>
              <%= dgettext("monitors", "SSL Expiry alerts") %>
            </span>
            <span class="text-muted-foreground text-sm font-normal leading-snug">
              When to send SSL (HTTPS) alerts before expiry.
            </span>
          </label>
          <div>
            <.form for={@form}>
              <.input type="select" options={@resend_interval_options} field={@form[:resend_interval]} />
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      assigns.notification_rule
      |> NotificationRule.changeset(%{})
      |> to_form()

    timeout_options = translated_select_enums(NotificationRule, :timeout)
    interval_options = translated_select_enums(NotificationRule, :resend_interval)

    socket =
      socket
      |> assign(
        form: form,
        timeout_options: timeout_options,
        resend_interval_options: interval_options,
        telegram_bot_info: nil
      )
      |> assign(assigns)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-via", %{"id" => id, "attr" => attr, "value" => value}, socket) do
    case Monitors.toggle_via(id, attr, value) do
      {:ok, notification_rule} ->
        notification_rule = Sentinel.Repo.preload(notification_rule, :webhook)
        {:noreply, assign(socket, :notification_rule, notification_rule)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, dgettext("errors", "Something went wrong"))}
    end
  end

  def handle_event("update-webhook", %{"notification_rule" => params}, socket) do
    params =
      if Map.get(params, "webhook_id") == nil do
        Map.put(params, "via_webhook", false)
      else
        Map.put(params, "via_webhook", true)
      end

    case Monitors.update_notification_rule(socket.assigns.notification_rule, params) do
      {:ok, notification_rule} ->
        notify_parent({:updated, notification_rule})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("update-telegram", %{"notification_rule" => params}, socket) do
    params =
      if Map.get(params, "telegram_bot_id") == nil do
        Map.put(params, "via_telegram", false)
      else
        Map.put(params, "via_telegram", true)
      end

    case Monitors.update_notification_rule(socket.assigns.notification_rule, params) do
      {:ok, notification_rule} ->
        notify_parent({:updated, notification_rule})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("sync-telegram", _params, socket) do
    notification_rule = socket.assigns.notification_rule
    monitor = socket.assigns.monitor
    telegram_bot = Integrations.get_telegram_bot!(notification_rule.telegram_bot_id, monitor.account_id)

    {:ok, updates} =
      Telegram.Api.request(telegram_bot.token, "getUpdates", allowed_updates: ["my_chat_member"], offset: -1)

    {:noreply, assign(socket, telegram_bot_info: Integrations.parse_bot_my_chat_member_updates(updates))}
  end

  def bot_info(assigns) do
    ~H"""
    <div class="text-muted-foreground mt-2 text-sm font-normal leading-snug">
      <p>
        <%= dgettext("monitors", "Chat id") %>: <%= @telegram_bot_info.chat.id %>
      </p>
      <p>
        <%= dgettext("monitors", "Chat title") %>: <%= @telegram_bot_info.chat.title %>
      </p>
      <p>
        <%= dgettext("monitors", "Bot name") %>: <%= @telegram_bot_info.bot_info.bot_name %>
      </p>
    </div>
    """
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
