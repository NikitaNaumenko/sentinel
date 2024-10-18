defmodule Sentinel.Monitors.UseCases.CreateMonitor do
  @moduledoc """
  This module defines the `CreateMonitor` use case for the Sentinel application.

  The primary purpose of this module is to encapsulate the logic for creating a new
  monitoring entity within the system. It is responsible for checking the validity of
  the provided certificate, constructing the monitor attributes, creating a new monitor
  record, and initiating monitoring by starting a MonitorWorker process.

  ## Usage

      alias Sentinel.Monitors.UseCases.CreateMonitor

      # Attributes for the new monitor
      monitor_attrs = %{
        "url" => "https://example.com",
        "monitor_type" => "uptime",
        # More attributes...
      }

      # Create a new monitor and start the monitoring process
      case CreateMonitor.call(account_id, monitor_attrs) do
        {:ok, monitor} ->
          # Monitor created successfully
        {:error, changeset} ->
          # Handle error
      end

  ## Functions

    - `call/2`: Takes an account_id and a map of monitor attributes, validates the
      certificate, and creates a new monitor.

  Note that this module should only be used as part of the Sentinel domain logic and
  not directly from the user interface or external applications.

  """

  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorWorker
  alias Sentinel.Monitors.UseCases.CheckCertificate
  alias Sentinel.Repo

  def call(monitor_attrs) do
    certificate = CheckCertificate.call(monitor_attrs["url"])

    attrs =
      Map.put(monitor_attrs, "certificates", [certificate])

    with {:ok, monitor} <- create_monitor(attrs),
         {:ok, _pid} <- MonitorWorker.start_link(monitor) do
      {:ok, monitor}
    end
  end

  defp create_monitor(attrs) do
    %Monitor{}
    |> Monitor.changeset(attrs)
    |> Repo.insert()
  end
end
