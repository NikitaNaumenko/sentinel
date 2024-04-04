defmodule Sentinel.Monitors.RequestTelemetry do
  @moduledoc false

  require Logger

  def attach do
    :ok =
      :telemetry.attach(
        # unique handler id
        "finch-response-handler",
        [:finch, :recv, :stop],
        &__MODULE__.handle_event/4,
        nil
      )
  end

  def handle_event([:finch, :recv, :stop], measurements, metadata, _config) do
    Logger.info("[#{inspect(metadata)}] #{inspect(measurements)}")
  end
end
