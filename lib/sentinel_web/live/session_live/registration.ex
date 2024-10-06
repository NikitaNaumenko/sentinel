defmodule SentinelWeb.SessionLive.Registration do
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
    <h2 class="h2 mb-4 text-center"><%= dgettext("sessions", "Sign up") %></h2>
    <.error :if={@check_errors}>
      Oops, something went wrong! Please check the errors below.
    </.error>

    <.simple_form
      for={@form}
      phx-trigger-action={@trigger_submit}
      phx-change="validate"
      phx-submit="save"
      id="registration_form"
      method="post"
      action={~p"/users/log_in?_action=registered"}
    >
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
    <div class="hr-text">or</div>
    <div class="row">
      <div class="col">
        <a href="#" class="btn w-100">
          Sign up with Github
        </a>
      </div>
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
            &url(~p"/confirm/#{&1}")
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

  # defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #   form = to_form(changeset, as: "user")

  #   if changeset.valid? do
  #     assign(socket, form: form, check_errors: false)
  #   else
  #     assign(socket, form: form)
  #   end
  # end
end
