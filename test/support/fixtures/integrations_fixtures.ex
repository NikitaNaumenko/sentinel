defmodule Sentinel.IntegrationsFixtures do
  @moduledoc false
  alias Sentinel.Integrations
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Repo

  def webhook_fixture(attrs \\ %{}) do
    attrs = Map.merge(%{name: "Webhook", endpoint: "http://example.com"}, attrs)

    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert!()
  end

  def telegram_fixture(attrs \\ %{}) do
    attrs = Map.merge(attrs, %{name: "Telegram bot", chat_id: Ecto.UUID.generate()})

    {:ok, bot} = Integrations.create_telegram(attrs)
    bot
  end
end
