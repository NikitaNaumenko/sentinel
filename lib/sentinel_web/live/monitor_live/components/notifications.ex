defmodule SentinelWeb.MonitorLive.Components.Notifications do
  @moduledoc false
  use SentinelWeb, :live_component

  alias Sentinel.Escalations
  alias Sentinel.Integrations
  alias Sentinel.Monitors
  # alias Sentinel.Monitors.NotificationRule

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <div class="fw-semibold">
        <%= dgettext("monitors", "Notification rules") %>
      </div>

      <div class="card cad-md mb-3">
        <div class="card-body">
          <div class="vstack gap-1">
            <%= if Enum.count(@escalation_policies) > 1 do %>
              <label>
                <span class="d-flex">
                  <%= dgettext("monitors", "Escalation policies") %>
                </span>
                <span class="text-muted-foreground text-sm font-normal leading-snug">
                  <%= dgettext(
                    "monitors",
                    "Set rules on how alerts escalade during an incident. It defines the order of channels that will be triggered for alerts."
                  ) %>
                </span>
              </label>
              <div>
                <.form phx-target={@myself} phx-change="update-escalation-policy" for={@form}>
                  <.input type="select" options={@escalation_policies} field={@form[:escalation_policy_id]} />
                </.form>
              </div>
              <div>
                <.link navigate={~p"/escalation_policies/new"}>
                  <%= dgettext("monitors", "Create new escalation policy") %>
                </.link>
              </div>
            <% else %>
              <span>
                <%= dgettext("monitors", "Please set up escalation policy to get incidents alert instantly") %>

                <div class="mt-2">
                  <.link navigate={~p"/escalation_policies/new"}>
                    <%= dgettext("monitors", "Create new escalation policy") %>
                  </.link>
                </div>
              </span>
            <% end %>
          </div>
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
            <%!-- <.form for={@form}>
              <.input type="select" options={@resend_interval_options} field={@form[:resend_interval]} />
            </.form> --%>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    escalation_policies =
      assigns.account_id
      |> Escalations.list_escalation_policies()
      |> collection_for_select({:id, :name}, empty: {dgettext("monitors", "No escalation policy"), nil})

    socket =
      socket
      |> assign(:escalation_policies, escalation_policies)
      |> assign(assigns)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("update-escalation-policy", %{"monitor" => params}, socket) do
    case Monitors.update_monitor(socket.assigns.monitor, params) do
      {:ok, monitor} ->
        notify_parent({:updated, monitor})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  # def handle_event("update-telegram", %{"notification_rule" => params}, socket) do
  #   params =
  #     if Map.get(params, "telegram_id") == nil do
  #       Map.put(params, "via_telegram", false)
  #     else
  #       Map.put(params, "via_telegram", true)
  #     end

  #   case Monitors.update_notification_rule(socket.assigns.notification_rule, params) do
  #     {:ok, notification_rule} ->
  #       notify_parent({:updated, notification_rule})
  #       {:noreply, socket}

  #     {:error, changeset} ->
  #       {:noreply, assign(socket, :form, to_form(changeset))}
  #   end
  # end

  # def handle_event("sync-telegram", _params, socket) do
  #   notification_rule = socket.assigns.notification_rule
  #   monitor = socket.assigns.monitor
  #   telegram = Integrations.get_telegram!(notification_rule.telegram_id, monitor.account_id)

  #   {:ok, updates} =
  #     Telegram.Api.request(telegram.token, "getUpdates", allowed_updates: ["my_chat_member"], offset: -1)

  #   {:noreply, assign(socket, telegram_info: Integrations.parse_bot_my_chat_member_updates(updates))}
  # end

  def bot_info(assigns) do
    ~H"""
    <div class="text-muted-foreground mt-2 text-sm font-normal leading-snug">
      <p>
        <%= dgettext("monitors", "Chat id") %>: <%= @telegram_info.chat.id %>
      </p>
      <p>
        <%= dgettext("monitors", "Chat title") %>: <%= @telegram_info.chat.title %>
      </p>
      <p>
        <%= dgettext("monitors", "Bot name") %>: <%= @telegram_info.bot_info.bot_name %>
      </p>
    </div>
    """
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
