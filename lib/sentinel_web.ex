defmodule SentinelWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use SentinelWeb, :controller
      use SentinelWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Plug.Conn
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: SentinelWeb.Layouts]

      import Plug.Conn
      import SentinelWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {SentinelWeb.Layouts, :app}

      alias SentinelWeb.Hooks.AuthorizeHook

      unquote(html_helpers())

      defp assign_form(socket, changeset) do
        assign(socket, :form, to_form(changeset))
      end
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      use PhoenixHTMLHelpers
      use SentinelWeb.Components

      import Bodyguard, only: [permit?: 4, permit?: 3]
      import Phoenix.HTML

      # Core UI components and translation
      import SentinelWeb.CoreComponents
      import SentinelWeb.EnumHelpers
      import SentinelWeb.FormHelpers
      import SentinelWeb.Gettext
      import SentinelWeb.HTMLHelpers
      import SentinelWeb.StatusCodes

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
      alias Sentinel.Cldr
      alias SentinelWeb.Components.Sidebar

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      # defdelegate dt(context, key), to: SentinelWeb.Gettext, as: :dgettext
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: SentinelWeb.Endpoint,
        router: SentinelWeb.Router,
        statics: SentinelWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
