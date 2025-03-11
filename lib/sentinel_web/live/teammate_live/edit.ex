defmodule SentinelWeb.TeammateLive.Edit do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Teammates
  alias Sentinel.Teammates.User

  def mount(%{"id" => id}, _session, socket) do
    teammate = Teammates.get_teammate!(socket.assigns.current_account.id, id)

    changeset = Teammates.User.changeset(teammate, %{})
    socket =
      socket
      |> assign(:page_title, dgettext("teammates", "Edit Teammate"))
      |> assign(:teammate, teammate)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => teammate_params}, socket) do
    changeset = User.changeset(socket.assigns.teammate, teammate_params)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("block", %{"user_id" => user_id}, socket) do
    case Teammates.block_teammate(%{"user_id" => user_id, "account_id" => socket.assigns.current_account.id}) do
      {:ok, _teammate} ->
        socket =
          socket
          |> put_flash(:info, dgettext("teammates", "Teammate blocked successfully."))
          |> push_navigate(to: ~p"/teammates")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end

  end

  def handle_event("save", %{"user" => teammate_params}, socket) do
    case Teammates.update_teammate(socket.assigns.teammate, teammate_params) do
      {:ok, _teammate} ->
        socket =
          socket
          |> put_flash(:info, dgettext("teammates", "Teammate created successfully. Invite was sent"))
          |> push_navigate(to: ~p"/teammates")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

end
