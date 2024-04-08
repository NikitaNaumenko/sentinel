defmodule Sentinel.Integrations do
  @moduledoc false
  import Ecto.Query

  alias Sentinel.Integrations.TelegramBot
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Repo

  @spec get_webhook!(non_neg_integer()) :: Webhook.t()
  def get_webhook!(id) do
    Repo.get!(Webhook, id)
  end

  @spec get_account_webhook(non_neg_integer()) :: Webhook.t() | nil
  def get_account_webhook(id) do
    Webhook
    |> where([w], w.account_id == ^id)
    |> Repo.one()
  end

  @spec create_webhook(attrs :: map()) :: {:ok, Webhook.t()} | {:error, Ecto.Changeset.t()}
  def create_webhook(attrs) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_webhook(Webhook.t(), attrs :: map()) :: {:ok, Webhook.t()} | {:error, Ecto.Changeset.t()}
  def update_webhook(webhook, attrs) do
    webhook
    |> Webhook.changeset(attrs)
    |> Repo.update()
  end

  def list_webhooks(account) do
    Webhook
    |> where([w], w.account_id == ^account.id)
    |> order_by(asc: :id)
    |> Repo.all()
  end

  def list_telegram_bots(account) do
    TelegramBot
    |> where([t], t.account_id == ^account.id)
    |> order_by(asc: :id)
    |> Repo.all()
  end

  @spec create_telegram_bot(attrs :: map()) :: {:ok, TelegramBot.t()} | {:error, Ecto.Changeset.t()}
  def create_telegram_bot(attrs) do
    %TelegramBot{}
    |> TelegramBot.changeset(attrs)
    |> Repo.insert()
  end
end
