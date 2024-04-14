defmodule SentinelWeb.TeammateLive.New do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Accounts
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
      {:ok, teammate} ->
        # TODO: Should work through the Events module
        Accounts.deliver_user_confirmation_instructions(teammate, &url(~p"/confirm/#{&1}"))

        socket =
          socket
          |> put_flash(:info, dgettext("teammates", "Teammate created successfully. Invite was sent"))
          |> push_navigate(to: ~p"/teammates")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def header(assigns) do
    ~H"""
    <header class="mr-auto ml-auto flex max-w-2xl items-center justify-between gap-6 py-2">
      <div>
        <h1 class="text-primary leading text-3xl font-bold leading-8">
          <%= @page_title %>
        </h1>
      </div>
    </header>
    """
  end
end
