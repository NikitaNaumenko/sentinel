defmodule SentinelWeb.TeammateLive.New do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Teammates
  alias Sentinel.Teammates.User

  def mount(_params, _session, socket) do
    changeset = User.changeset(%User{}, %{})

    socket =
      socket
      |> assign(:page_title, dgettext("teammates", "New Teammate"))
      |> assign(:teammate, %User{})
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => teammate_params}, socket) do
    changeset = User.changeset(socket.assigns.teammate, teammate_params)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => teammate_params}, socket) do
    case Teammates.create_teammate(Map.put(teammate_params, "account_id", socket.assigns.current_account.id)) do
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
