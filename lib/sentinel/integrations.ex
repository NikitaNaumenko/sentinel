defmodule Sentinel.Integrations do
  @moduledoc false
  import Ecto.Query

  alias Sentinel.Accounts.Account
  alias Sentinel.Integrations.SlackWebhook
  alias Sentinel.Integrations.Telegram
  alias Sentinel.Integrations.Webhook
  alias Sentinel.Repo

  @spec get_webhook!(non_neg_integer(), non_neg_integer()) :: Webhook.t()
  def get_webhook!(id, account_id) do
    Repo.get_by!(Webhook, id: id, account_id: account_id)
  end

  @spec get_slack_webhook!(non_neg_integer(), non_neg_integer()) :: SlackWebhook.t()
  def get_slack_webhook!(id, account_id) do
    Repo.get_by!(SlackWebhook, id: id, account_id: account_id)
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

  def list_webhooks(%Account{id: account_id}) do
    Webhook
    |> where([w], w.account_id == ^account_id)
    |> order_by(asc: :id)
    |> Repo.all()
  end

  def get_telegram!(id, account_id) do
    Repo.get_by!(Telegram, id: id, account_id: account_id)
  end

  def list_telegrams(%Account{id: account_id}) do
    Telegram
    |> where([t], t.account_id == ^account_id)
    |> order_by(asc: :id)
    |> Repo.all()
  end

  @spec create_telegram(attrs :: map()) :: {:ok, Telegram.t()} | {:error, Ecto.Changeset.t()}
  def create_telegram(attrs) do
    %Telegram{}
    |> Telegram.changeset(attrs)
    |> Repo.insert()
  end

  def update_telegram(telegram, attrs) do
    telegram
    |> Telegram.changeset(attrs)
    |> Repo.update()
  end

  def parse_bot_my_chat_member_updates(updates) do
    updates
    |> Enum.filter(
      &(Map.has_key?(&1, "my_chat_member") &&
          get_in(&1, ["my_chat_member", "new_chat_member", "user", "is_bot"]))
    )
    |> dbg()
    |> Enum.map(fn value ->
      %{
        chat: %{
          id: get_in(value, ["my_chat_member", "chat", "id"]),
          title: get_in(value, ["my_chat_member", "chat", "title"])
        },
        bot_info: %{bot_name: get_in(value, ["my_chat_member", "new_chat_member", "user", "username"])}
      }
    end)
  end

  @spec create_slack_webhook(attrs :: map()) :: {:ok, SlackWebhook.t()} | {:error, Ecto.Changeset.t()}
  def create_slack_webhook(attrs) do
    %SlackWebhook{}
    |> SlackWebhook.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_slack_webhook(SlackWebhook.t(), attrs :: map()) ::
          {:ok, SlackWebhook.t()} | {:error, Ecto.Changeset.t()}
  def update_slack_webhook(slack, attrs) do
    slack
    |> SlackWebhook.changeset(attrs)
    |> Repo.update()
  end

  def list_slack_webhooks(%Account{id: account_id}) do
    SlackWebhook
    |> where([s], s.account_id == ^account_id)
    |> order_by(asc: :id)
    |> Repo.all()
  end
end
