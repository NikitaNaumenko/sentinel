defmodule Sentinel.Integrations do
  @moduledoc false
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Repo

  def create_webhook(attrs) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end
end
