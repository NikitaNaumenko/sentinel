defmodule SentinelWeb.TeammateLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Teammates

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :teammates, Teammates.list_teammates(socket.assigns.current_account.id))}
  end
end
