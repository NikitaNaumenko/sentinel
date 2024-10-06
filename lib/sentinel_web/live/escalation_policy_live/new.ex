defmodule SentinelWeb.EscalationPolicyLive.New do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Accounts
  alias Sentinel.Escalations
  alias Sentinel.Escalations.Alert
  alias Sentinel.Escalations.EscalationPolicy
  alias Sentinel.Escalations.Policy
  alias Sentinel.Escalations.Step
  alias Sentinel.Integrations

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
  def handle_event("validate", %{"policy" => escalation_policy_attrs}, socket) do
    dbg(escalation_policy_attrs)

    changeset =
      %Policy{}
      |> Escalations.escalation_policy_changeset(escalation_policy_attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("add-step", _, socket) do
    step = Escalations.escalation_step_changeset()

    socket =
      update(socket, :form, fn %{source: policy_changeset} ->
        existing_steps = get_change_or_field(policy_changeset, :escalation_steps)

        policy_changeset =
          Ecto.Changeset.put_assoc(policy_changeset, :escalation_steps, existing_steps ++ [step])

        to_form(policy_changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("add-alert", %{"value" => index}, socket) do
    alert_changeset = Escalations.escalation_alert_changeset()

    socket =
      update(socket, :form, fn %{source: policy_changeset} ->
        steps = get_change_or_field(policy_changeset, :escalation_steps)
        step_changeset = Enum.at(steps, String.to_integer(index))
        existing_alerts = get_change_or_field(step_changeset, :escalation_alerts)

        step_changeset =
          Ecto.Changeset.put_assoc(step_changeset, :escalation_alerts, existing_alerts ++ [alert_changeset])

        policy_changeset =
          Ecto.Changeset.put_assoc(
            policy_changeset,
            :escalation_steps,
            List.replace_at(steps, String.to_integer(index), step_changeset)
          )

        to_form(policy_changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("delete-step", %{"value" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_assoc(changeset, :escalation_steps)
        {to_delete, rest} = List.pop_at(existing, index)

        steps =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset
        |> Ecto.Changeset.put_assoc(:escalation_steps, steps)
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("delete-alert", %{"alert_index" => alert_index, "step_index" => step_index}, socket) do
    # alert_index = String.to_integer(alert_index)
    # step_index = String.to_integer(step_index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        steps = Ecto.Changeset.get_assoc(changeset, :escalation_steps)
        step_changeset = Enum.at(steps, step_index)
        alerts = Ecto.Changeset.get_assoc(step_changeset, :escalation_alerts)
        {to_delete, rest} = List.pop_at(alerts, alert_index)

        alerts =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(alerts, alert_index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        step_changeset =
          Ecto.Changeset.put_assoc(step_changeset, :escalation_alerts, alerts)

        changeset
        |> Ecto.Changeset.put_assoc(
          :escalation_steps,
          List.replace_at(steps, step_index, step_changeset)
        )
        |> to_form()
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
