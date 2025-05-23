defmodule Sentinel.MixProject do
  use Mix.Project

  def project do
    [
      app: :sentinel,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:yecc, :finitomata] ++ Mix.compilers(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Sentinel.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.19"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      # {:phoenix_live_dashboard, "~> 0.8.2"},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.4"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.0"},
      {:ecto_enum_migration, "~> 0.3.4"},
      {:oban, "~> 2.16"},
      {:x509, "~> 0.8"},
      {:ex_cldr, "~> 2.0"},
      {:ex_cldr_dates_times, "~> 2.0"},
      {:ex_cldr_numbers, "~> 2.0"},
      {:ex_cldr_calendars, "~> 1.23"},
      {:recase, "~> 0.5"},
      # {:cva, "~> 0.2"},
      {:ecto_commons, "~> 0.3.4"},
      {:finitomata, "~> 0.1"},
      {:bodyguard, "~> 2.4.3"},
      {:telegram, github: "visciang/telegram", tag: "1.2.1"},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:tailwind_formatter, "~> 0.4.0", only: [:dev, :test], runtime: false},
      {:exvcr, "~> 0.11", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:repatch, "~> 1.0"},
      {:dotenv, "~> 3.0.0", only: [:dev, :test]},
      {:faker, "~> 0.19.0-alpha.1", only: [:dev, :test]},
      {:ex_machina, "~> 2.8", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["cmd npm run deploy --prefix assets"]
    ]
  end
end
