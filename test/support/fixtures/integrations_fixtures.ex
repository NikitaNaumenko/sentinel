defmodule Sentinel.IntegrationsFixtures do
  @moduledoc false
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Repo

  def webhook_fixture(attrs \\ %{}) do
    attrs = Map.merge(%{endpoint: "http://example.com"}, attrs)

    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert!()
  end
end
