defmodule SentinelWeb.Hooks.AuthorizeHook do
  @moduledoc """
  Authorize hook for Liveview, which checks if user is authorized to access to resource or route.
  """
  use SentinelWeb, :verified_routes

  import Phoenix.LiveView
  import SentinelWeb.Gettext, only: [dgettext: 2]

  def on_mount(
        [policy: policy],
        _params,
        _session,
        %Phoenix.LiveView.Socket{assigns: %{current_user: current_user, live_action: action}} = socket
      ) do
    case Bodyguard.permit(policy, action, current_user) do
      :ok ->
        {:cont, socket}

      _error ->
        {:halt, socket_redirect(socket)}
    end
  end

  def on_mount(
        [policy: policy, extract_params: {extract_fun, record_name, attr}],
        params,
        _session,
        %Phoenix.LiveView.Socket{assigns: %{current_user: current_user, live_action: action}} = socket
      ) do
    record = extract_fun.(Map.get(params, attr))

    case Bodyguard.permit(policy, action, current_user, record) do
      :ok ->
        {:cont, Phoenix.Component.assign(socket, record_name, record)}

      _error ->
        {:halt, socket_redirect(socket)}
    end
  end

  def on_mount(_policy, _params, _session, socket) do
    {:halt, socket_redirect(socket)}
  end

  defp socket_redirect(socket) do
    socket
    |> put_flash(:error, dgettext("errors", "You are not authorized to access this page"))
    |> redirect(to: "/")
  end
end
