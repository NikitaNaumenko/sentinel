defmodule SentinelWeb.SessionLive.Login do
  @moduledoc false
  use SentinelWeb, :live_view

  def render(assigns) do
    ~H"""
    <.link
      navigate={~p"/registration"}
      class="absolute top-4 right-4 inline-flex h-9 items-center justify-center whitespace-nowrap rounded-md px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:pointer-events-none disabled:opacity-50 md:top-8 md:right-8"
    >
      <%= dgettext("sessions", "Sign up") %>
    </.link>
    <h2 class="h2 mb-4 text-center"><%= dgettext("session", "Log in") %></h2>
    <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
      <.input field={@form[:email]} type="email" label="Email" required />
      <.input field={@form[:password]} type="password" label="Password" required />

      <:actions>
        <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
        <.link href={~p"/reset_password"} class="text-sm font-semibold">
          Forgot your password?
        </.link>
      </:actions>
      <:actions>
        <.button phx-disable-with="Signing in..." class="w-full">
          Log in <span aria-hidden="true">→</span>
        </.button>
      </:actions>
    </.simple_form>
    <div class="hr-text">or</div>
    <div class="row">
      <div class="col">
        <a href="#" class="btn w-100">
          Login with Github
        </a>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
