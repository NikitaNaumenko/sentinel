defmodule Sentinel.Events.UseCases.SendWebhook do
  @moduledoc false
  def call(%{acceptor: acceptor, recipient: recipient, resource: resource, event_type: event_type}) do
    :sent
  end
end
