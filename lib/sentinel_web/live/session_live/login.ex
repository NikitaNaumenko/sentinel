defmodule SentinelWeb.SessionLive.Login do
  @moduledoc false
  use SentinelWeb, :live_view

  def render(assigns) do
    ~H"""
    <h2 class="h2 mb-4 text-center">{dgettext("session", "Log in")}</h2>
    <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
      <.input field={@form[:email]} type="email" label="Email" required />

      <.input field={@form[:password]} type="password" label="Password" required />

      <:actions>
        <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
      </:actions>
      <:actions>
        <.button phx-disable-with="Signing in..." class="w-full">
          Log in <span aria-hidden="true">→</span>
        </.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
