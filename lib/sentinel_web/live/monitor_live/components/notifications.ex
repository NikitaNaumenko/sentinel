defmodule SentinelWeb.MonitorLive.Components.Notifications do
  @moduledoc false
  use SentinelWeb, :live_component

  alias Sentinel.Monitors
  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.NotificationRule

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-card text-card-foreground mb-5 flex flex-col rounded-lg border p-6 shadow-sm md:flex-row">
        <div class="flex w-full items-center justify-between space-x-4">
          <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
            <span>
              <%= dgettext("monitors", "Activate monitoring") %>
            </span>
            <span class="text-muted-foreground text-sm font-normal leading-snug">
              When unchecked, Sentinel will stop pinging this monitor.
            </span>
          </label>
          <div>
            <.switch
              checked={active?(assigns.monitor)}
              on_click={JS.push("toggle-monitor", value: %{id: @monitor.id})}
            />
          </div>
        </div>
      </div>

      <div class="text-muted-foreground text-sm">
        <%= dgettext("monitors", "Notification Rules") %>
      </div>

      <div class="bg-card text-card-foreground flex flex-col rounded-lg border p-6 shadow-sm">
        <label class="flex flex-col space-y-1 font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
          <span>
            <%= dgettext("monitors", "Team level notifications") %>
          </span>
          <span class="text-muted-foreground text-sm font-normal leading-snug">
            You will receive notifications for the enabled channels that are configured. To send emails & SMS to specific teammates, please configure an escalation policy.
          </span>
        </label>
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
          <div class="mr-5">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              phx-target={@myself}
              phx-click={
                JS.push("toggle-via",
                  value: %{id: @notification_rule.id, attr: "via_webhook", value: @notification_rule.via_webhook}
                )
              }
            >
              <input
                type="checkbox"
                id="webhook"
                name="via_webhook"
                value="true"
                checked={@notification_rule.via_webhook}
                class="border-primary text-primary rounded focus:ring-0"
              />
              <%= dgettext("monitors", "Webhook") %>
            </label>
          </div>
          <div class="mr-5">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              phx-target={@myself}
              phx-click={
                JS.push("toggle-via",
                  value: %{id: @notification_rule.id, attr: "via_telegram", value: @notification_rule.via_telegram}
                )
              }
            >
              <input
                type="checkbox"
                id="telegram"
                name="via_telegram"
                value="true"
                checked={@notification_rule.via_telegram}
                class="border-primary text-primary rounded focus:ring-0"
              />
              <%= dgettext("monitors", "Telegram") %>
            </label>
          </div>
        </div>
        <div :if={@notification_rule.via_webhook} class="mt-5">
          <.simple_form
            for={@form}
            phx-target={@myself}
            phx-submit="update-webhook-url"
            phx-change="validate-webhook-url"
          >
            <%= inputs_for @form, :webhook, fn webhook -> %>
              <.input field={webhook[:endpoint]} label={dgettext("notification_rule", "Webhook url")} />
            <% end %>
            <:actions>
              <.button phx-disable-with="Saving..."><%= dgettext("forms", "Save") %></.button>
            </:actions>
          </.simple_form>
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
        </div>
      </div>
      <div class="text-muted-foreground mt-10 text-sm">
        <%= dgettext("monitors", "SSL monitoring") %>
      </div>

      <div class="bg-card text-card-foreground flex flex-col rounded-lg border p-4 shadow-sm">
        <div class="flex w-full items-center justify-between space-x-4">
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
      |> assign(form: form, timeout_options: timeout_options, resend_interval_options: interval_options)
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

  def handle_event("validate-webhook-url", %{"notification_rule" => params}, socket) do
    changeset =
      socket.assigns.notification_rule
      |> NotificationRule.changeset(Map.put(params, "account_id", socket.assigns.account_id))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("update-webhook-url", %{"notification_rule" => params}, socket) do
    params = put_in(params, ["webhook", "account_id"], socket.assigns.account_id)

    case Monitors.update_notification_rule(socket.assigns.notification_rule, params) do
      {:ok, notification_rule} ->
        notify_parent({:updated, notification_rule})

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp active?(%Monitor{state: :active}), do: true
  defp active?(_), do: false

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
