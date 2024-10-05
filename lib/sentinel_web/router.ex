defmodule SentinelWeb.Router do
  use SentinelWeb, :router

  import SentinelWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SentinelWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SentinelWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", SentinelWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sentinel, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    # import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      # live_dashboard "/dashboard", metrics: SentinelWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SentinelWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SentinelWeb.UserAuth, :redirect_if_user_is_authenticated}],
      layout: {SentinelWeb.Layouts, :auth} do
      live "/registration", SessionLive.Registration, :new
      live "/log_in", SessionLive.Login, :new
      live "/reset_password", SessionLive.ForgotPassword, :new
      live "/reset_password/:token", SessionLive.ResetPassword, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SentinelWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SentinelWeb.UserAuth, :ensure_authenticated}],
      layout: {SentinelWeb.Layouts, :app} do
      live "/monitors", MonitorLive.Index, :index
      live "/monitors/new", MonitorLive.New, :new
      live "/monitors/:id", MonitorLive.Show, :show
      live "/monitors/:id/edit", MonitorLive.Edit, :edit
      live "/status_pages", PageLive.Index, :index
      live "/status_pages/:id", PageLive.Show, :index
      live "/status_pages/new", PageLive.New, :new
      # live "/users/settings", UserSettingsLive, :edit
      # live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/integrations", IntegrationLive.Index, :index
      live "/integrations/webhooks/new", IntegrationLive.NewWebhook, :new_webhook
      live "/integrations/webhooks/:id/edit", IntegrationLive.EditWebhook, :edit_webhook
      live "/integrations/telegram_bots/new", IntegrationLive.NewTelegramBot, :new_telegram_bots
      live "/integrations/telegram_bots/:id/edit", IntegrationLive.EditTelegramBot, :edit_telegram_bots

      live "/teammates", TeammateLive.Index, :index
      live "/teammates/new", TeammateLive.New, :new
    end
  end

  scope "/", SentinelWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SentinelWeb.UserAuth, :mount_current_user}],
      layout: {SentinelWeb.Layouts, :auth} do
      live "/confirm/:token", SessionLive.Confirmation, :edit
      live "/confirm", SessionLive.ConfirmationInstructions, :new
    end
  end
end
