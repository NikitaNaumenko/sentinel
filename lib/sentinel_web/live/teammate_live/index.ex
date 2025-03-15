defmodule SentinelWeb.TeammateLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Teammates
  alias Sentinel.Teammates.UserPolicy

  on_mount {AuthorizeHook, policy: UserPolicy}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :teammates, Teammates.list_teammates(socket.assigns.current_account.id))}
  end

  @impl Phoenix.LiveView
  def handle_event("block", %{"id" => id}, socket) do
    {:noreply, Teammates.block_teammate(id)}
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
