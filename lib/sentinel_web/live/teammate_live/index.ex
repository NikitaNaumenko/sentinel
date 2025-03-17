defmodule SentinelWeb.TeammateLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Teammates
  alias Sentinel.Teammates.UserPolicy

  on_mount {AuthorizeHook, policy: UserPolicy}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Teammates.list_users(socket.assigns.current_account.id), reset: true)}
  end

  @impl Phoenix.LiveView
  def handle_event("block", %{"id" => id}, socket) do
    case Teammates.block_user(id) do
      {:ok, user} ->
        socket =
          socket
          |> stream_insert(:users, user)
          |> put_flash(:success, gettext("Teammate blocked successfully"))

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to block teammate"))}
    end
  end

  def badge_variant(state) do
    case state do
      :created -> "warning"
      :waiting_confirmation -> "info"
      :active -> "success"
      :blocked -> "danger"
    end
  end
end
