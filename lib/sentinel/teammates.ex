defmodule Sentinel.Teammates do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Sentinel.Accounts.UserToken
  alias Sentinel.Events
  alias Sentinel.Repo
  alias Sentinel.Teammates.User

  def list_teammates(account_id) do
    User
    |> Bodyguard.scope(account_id)
    |> select_merge([u], %{full_name: fragment("CONCAT_WS(' ', last_name, first_name)")})
    |> Repo.all()
  end

  def get_teammate!(account_id, id) do
    Repo.one(from(u in User, where: u.id == ^id and u.account_id == ^account_id))
  end

  def create_teammate(params) do
    Repo.transaction(fn ->
      user =
        %User{}
        |> User.changeset(params)
        |> Repo.insert!()

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      Events.create_event(:teammate_created, user, %{token: encoded_token})
    end)
  end
end
