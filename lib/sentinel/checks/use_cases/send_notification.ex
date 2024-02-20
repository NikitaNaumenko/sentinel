defmodule Sentinel.Checks.UseCases.SendNotification do
  @moduledoc false
  alias Sentinel.Checks.Monitor

  @spec call(Monitor.t()) :: :ok | :error
  def call(_monitor) do
  end
end
