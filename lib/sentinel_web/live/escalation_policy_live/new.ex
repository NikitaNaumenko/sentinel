defmodule SentinelWeb.EscalationPolicyLive.New do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Escalations.EscalationPolicy
  alias Sentinel.Accounts
  alias Sentinel.Escalations
  alias Sentinel.Integrations
  alias Sentinel.Escalations.Step

  on_mount {AuthorizeHook, policy: EscalationPolicy}
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    account_id = socket.assigns.current_account.id
    changeset = Escalations.escalation_policy_changeset()

    users = Accounts.list_users(account_id)
    webhooks = Integrations.list_webhooks(account_id)
    telegram_bots = Integrations.list_telegram_bots(account_id)
    alert_types = Escalations.alert_types()

    socket =
      socket
      |> assign(:alert_types, alert_types)
      |> assign(:users, users)
      |> assign(:webhooks, webhooks)
      |> assign(:telegram_bots, telegram_bots)
      |> assign(:page_title, dgettext("escalation_policy", "Create new escalation policy"))
      |> assign(:title, dgettext("monitors", "New Escalation Policy"))
      |> assign_form(changeset)

    {:ok, socket}
  end

  def header(assigns) do
    ~H"""
    <header>
      <div class="col">
        <h2 class="page-title">
          <%= @page_title %>
        </h2>
      </div>
    </header>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("add", _, socket) do
    step= Step.changeset(%Step{})

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = get_change_or_field(changeset, :escalation_steps)
        changeset = Ecto.Changeset.put_assoc(changeset, :escalation_steps, existing ++ [step])
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  defp get_change_or_field(changeset, field) do
    with nil <- Ecto.Changeset.get_change(changeset, field) do
      Ecto.Changeset.get_field(changeset, field, [])
    end
  end

  # @impl Phoenix.LiveView
  # def handle_event("validate", %{"monitor" => monitor_attrs}, socket) do
  #   changeset =
  #     %Monitor{}
  #     |> Monitor.changeset(monitor_attrs)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign_form(socket, changeset)}
  # end

  # def handle_event("save", %{"monitor" => monitor_attrs}, socket) do
  #   case Monitors.create_monitor(Map.put(monitor_attrs, "account_id", socket.assigns.current_user.account_id)) do
  #     {:ok, monitor} ->
  #       socket =
  #         socket
  #         |> put_flash(:success, dgettext("monitors", "Monitor created successfully"))
  #         |> push_navigate(to: ~p"/monitors/#{monitor}")

  #       {:noreply, socket}

  #     {:error, {:already_started, _pid}} ->
  #       {:noreply, put_flash(socket, :error, dgettext("monitors", "Something went wrong"))}

  #     {:error, changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end
end
