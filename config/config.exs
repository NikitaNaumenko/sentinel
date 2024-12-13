# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :sentinel,
  ecto_repos: [Sentinel.Repo],
  generators: [timestamp_type: :utc_datetime_usec]

# Configures the endpoint
config :sentinel, SentinelWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: SentinelWeb.ErrorHTML, json: SentinelWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Sentinel.PubSub,
  live_view: [signing_salt: "lAs/gteO"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :sentinel, Sentinel.Mailer, adapter: Swoosh.Adapters.Local

config :ex_cldr,
  default_locale: :en,
  default_backend: Sentinel.Cldr

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :sentinel, Oban,
  repo: Sentinel.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [notifications: 5, monitors: 10]

config :sentinel, :telegram_bot_token, System.get_env("TELEGRAM_BOT_TOKEN", "")
config :sentinel, :telegram_client, Telegram.Api

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
