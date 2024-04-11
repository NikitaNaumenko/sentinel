defmodule Sentinel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = Oban.Telemetry.attach_default_logger()

    children = [
      SentinelWeb.Telemetry,
      Sentinel.Repo,
      {Oban, Application.fetch_env!(:sentinel, Oban)},
      {DNSCluster, query: Application.get_env(:sentinel, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sentinel.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Sentinel.Finch},
      {Registry, keys: :unique, name: Sentinel.Monitors.Registry},
      Sentinel.Monitors.MonitorSupervisor,
      Finitomata.Supervisor,

      # Start a worker by calling: Sentinel.Worker.start_link(arg)
      # {Sentinel.Worker, arg},
      # Start to serve requests, typically the last entry
      SentinelWeb.Endpoint
    ]

    Sentinel.Monitors.RequestTelemetry.attach()
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sentinel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SentinelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
