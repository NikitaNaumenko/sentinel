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
    account = socket.assigns.current_account
    changeset = Escalations.escalation_policy_changeset()

    users = account |> Accounts.list_users() |> collection_for_select({:id, :email})
    webhooks = account |> Integrations.list_webhooks() |> collection_for_select({:id, :name})
    telegram_bots = account |> Integrations.list_telegram_bots() |> collection_for_select({:id, :name})
    alert_types = Escalations.alert_types()

    socket =
      socket
      |> assign(:alert_types, alert_types)
      |> assign(:users, users)
      |> assign(:webhooks, webhooks)
      |> assign(:telegram_bots, telegram_bots)
      |> assign(:step_alert_types, %{})
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
    changeset =
      %Policy{}
      |> Escalations.escalation_policy_changeset(escalation_policy_attrs)
      |> dbg()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("change-alert-type", %{"_target" => target} = attrs, socket) do
    [_, _, step_index, _, alert_index, _] = target

    alert_type = get_in(attrs, target)

    socket =
      update(socket, :step_alert_types, fn alert_types ->
        default = alert_infos(alert_type, socket)

        Map.update(alert_types, "#{step_index}-#{alert_index}", default, fn _ ->
          alert_infos(alert_type, socket)
        end)
      end)

    socket =
      update(socket, :form, fn %{source: policy_changeset} ->
        step_index = String.to_integer(step_index)
        alert_index = String.to_integer(alert_index)
        steps = Ecto.Changeset.get_assoc(policy_changeset, :escalation_steps)
        step_changeset = Enum.at(steps, step_index)
        alerts = Ecto.Changeset.get_assoc(step_changeset, :escalation_alerts)

        alert_changeset = alerts |> Enum.at(alert_index) |> Ecto.Changeset.change(%{alert_type: alert_type})

        step_changeset =
          Ecto.Changeset.put_assoc(
            step_changeset,
            :escalation_alerts,
            List.replace_at(alerts, alert_index, alert_changeset)
          )

        policy_changeset
        |> Ecto.Changeset.put_assoc(
          :escalation_steps,
          List.replace_at(steps, step_index, step_changeset)
        )
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("add-step", _, socket) do
    step_changeset = Escalations.escalation_step_changeset()

    socket =
      update(socket, :form, fn %{source: policy_changeset} ->
        existing_steps = get_change_or_field(policy_changeset, :escalation_steps)

        policy_changeset
        |> Ecto.Changeset.put_assoc(:escalation_steps, existing_steps ++ [step_changeset])
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("add-alert", %{"step_index" => step_index}, socket) do
    alert_changeset = Escalations.escalation_alert_changeset()

    socket =
      update(socket, :form, fn %{source: policy_changeset} ->
        steps = get_change_or_field(policy_changeset, :escalation_steps)
        step_changeset = Enum.at(steps, step_index)
        existing_alerts = get_change_or_field(step_changeset, :escalation_alerts)

        step_changeset =
          Ecto.Changeset.put_assoc(step_changeset, :escalation_alerts, existing_alerts ++ [alert_changeset])

        policy_changeset
        |> Ecto.Changeset.put_assoc(
          :escalation_steps,
          List.replace_at(steps, step_index, step_changeset)
        )
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("delete-step", %{"step_index" => index}, socket) do
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

  def handle_event("save", %{"policy" => policy_attrs}, socket) do
    case Escalations.create_escalation_policy(
           Map.put(policy_attrs, "account_id", socket.assigns.current_user.account_id)
         ) do
      {:ok, policy} ->
        dbg(policy)

        socket =
          socket
          |> put_flash(:success, dgettext("escalation_policies", "Escalation policy created successfully"))
          |> push_navigate(to: ~p"/escalation_policies")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp alert_infos("users", socket), do: socket.assigns.users
  defp alert_infos("webhook", socket), do: socket.assigns.webhooks
  defp alert_infos("telegram_bot", socket), do: socket.assigns.telegram_bots
end
