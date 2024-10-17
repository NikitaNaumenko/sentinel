defmodule SentinelWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  import SentinelWeb.Components.Icon
  import SentinelWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})
  slot(:inner_block, required: true)

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="shadow-zinc-700/10 ring-zinc-700/10 relative hidden rounded-2xl bg-white shadow-lg ring-1 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="icon-x" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # @doc """
  # Shows the flash group with standard titles and content.
  #
  # ## Examples
  #
  #     <.flash_group flash={@flash} />
  # """
  # attr :flash, :map, required: true, doc: "the map of flash messages"
  # attr :id, :string, default: "flash-group", doc: "the optional id of flash container"
  #
  # def flash_group(assigns) do
  #   ~H"""
  #   <div id={@id}>
  #     <.flash kind={:info} title="Success!" flash={@flash} />
  #     <.flash kind={:error} title="Error!" flash={@flash} />
  #     <.flash
  #       id="client-error"
  #       kind={:error}
  #       title="We can't find the internet"
  #       phx-disconnected={show(".phx-client-error #client-error")}
  #       phx-connected={hide("#client-error")}
  #       hidden
  #     >
  #       Attempting to reconnect <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
  #     </.flash>
  #
  #     <.flash
  #       id="server-error"
  #       kind={:error}
  #       title="Something went wrong!"
  #       phx-disconnected={show(".phx-server-error #server-error")}
  #       phx-connected={hide("#server-error")}
  #       hidden
  #     >
  #       Hang in there while we get back on track
  #       <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
  #     </.flash>
  #   </div>
  #   """
  # end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, required: true, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)

  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between", @class]}>
      <div class="space-y-1">
        <h1 class="text-2xl font-semibold tracking-tight">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="text-muted-foreground text-sm">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div>
      <.link navigate={@navigate} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95", "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  attr(:page_title, :string, required: true)
  attr(:policy_func, :any, default: false)
  attr(:path, :any, required: true)
  attr(:link_title, :string, required: true)
  attr(:condition, :boolean, default: true)

  def index_page_header(assigns) do
    ~H"""
    <%= if @condition do %>
      <header class="d-flex">
        <div class="col">
          <h2 class="page-title">
            <%= @page_title %>
          </h2>
        </div>
        <div class="ms-auto d-print-none col-auto">
          <.link :if={@policy_func.()} navigate={@path} class="btn btn-primary">
            <%= @link_title %>
          </.link>
        </div>
      </header>
    <% end %>
    """
  end

  #
  # @doc """
  # Translates an error message using gettext.
  # """
  # def translate_error({msg, opts}) do
  #   # When using gettext, we typically pass the strings we want
  #   # to translate as a static argument:
  #   #
  #   #     # Translate the number of files with plural rules
  #   #     dngettext("errors", "1 file", "%{count} files", count)
  #   #
  #   # However the error messages in our forms and APIs are generated
  #   # dynamically, so we need to translate them by calling Gettext
  #   # with our gettext backend as first argument. Translations are
  #   # available in the errors.po file (as we use the "errors" domain).
  #   if count = opts[:count] do
  #     Gettext.dngettext(SentinelWeb.Gettext, "errors", msg, msg, count, opts)
  #   else
  #     Gettext.dgettext(SentinelWeb.Gettext, "errors", msg, opts)
  #   end
  # end
  #
  # @doc """
  # Translates the errors for a field from a keyword list of errors.
  # """
  # def translate_errors(errors, field) when is_list(errors) do
  #   for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  # end
end
