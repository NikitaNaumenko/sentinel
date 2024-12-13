import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sentinel, Sentinel.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "sentinel_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sentinel, SentinelWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ipLn1VNnwQWVYDvfTFalsJDGbPOKmC24DWYprcpHuRPpYuwPdlXyN+OJRty+LsKM",
  server: false

# In test we don't send emails.
config :sentinel, Sentinel.Mailer, adapter: Swoosh.Adapters.Test

config :sentinel,
  telegram_client: Sentinel.StubTelegramClient,
  telegram_bot_token: "7081666666:AAFMKLLnnnnnnnnnnnG18cIBrrrrrrrrrJQ"

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :sentinel, Oban, testing: :inline

config :exvcr,
  vcr_cassette_library_dir: "test/support/fixtures/vcr"
