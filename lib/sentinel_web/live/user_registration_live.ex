defmodule SentinelWeb.UserRegistrationLive do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Accounts
  alias Sentinel.Accounts.User

  def render(assigns) do
    ~H"""
    <.link
      navigate={~p"/log_in"}
      class="absolute top-4 right-4 inline-flex h-9 items-center justify-center whitespace-nowrap rounded-md px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:pointer-events-none disabled:opacity-50 md:top-8 md:right-8"
    >
      <%= dgettext("sessions", "Login") %>
    </.link>

    <div class="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
      <div class="flex flex-col space-y-2">
        <h1 class="text-center text-2xl font-semibold tracking-tight">Create an account</h1>
        <p class="text-muted-foreground text-center text-sm">Enter your data below to create your account</p>
        <.simple_form
          for={@form}
          phx-update="ignore"
          phx-trigger-action={@trigger_submit}
          phx-change="validate"
          phx-submit="save"
          id="registration_form"
          method="post"
          action={~p"/users/log_in?_action=registered"}
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.inputs_for :let={f_nested} field={@form[:account]}>
            <.input field={f_nested[:name]} type="text" label="Account name" required />
          </.inputs_for>
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.button phx-disable-with="Creating account..." class="w-full">
              Create account
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
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
