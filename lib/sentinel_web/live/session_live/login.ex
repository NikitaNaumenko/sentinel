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

    <div class="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
      <div class="flex flex-col space-y-2">
        <h1 class="text-center text-2xl font-semibold tracking-tight"><%= dgettext("session", "Log in") %></h1>
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
      </div>
      <div class="grid gap-6">
        <div class="relative">
          <div class="absolute inset-0 flex items-center"><span class="w-full border-t"></span></div>
          <div class="relative flex justify-center text-xs uppercase">
            <span class="bg-background text-muted-foreground px-2">Or continue with</span>
          </div>
        </div>
        <button
          class="border-input bg-background inline-flex h-9 items-center justify-center whitespace-nowrap rounded-md border px-4 py-2 text-sm font-medium shadow-sm transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:pointer-events-none disabled:opacity-50"
          type="button"
        >
          GitHub
        </button>
      </div>
      <p class="text-muted-foreground px-8 text-center text-sm">
        By clicking continue, you agree to our
        <a class="underline underline-offset-4 hover:text-primary" href="#">Terms of Service</a>
        and <a class="underline underline-offset-4 hover:text-primary" href="#">Privacy Policy</a>.
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
