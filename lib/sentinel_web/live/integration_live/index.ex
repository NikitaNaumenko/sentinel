defmodule SentinelWeb.IntegrationLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view


  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
