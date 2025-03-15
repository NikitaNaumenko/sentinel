defmodule Sentinel.Teammates do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Sentinel.Accounts.UserToken
  alias Sentinel.Events
  alias Sentinel.Repo
  alias Sentinel.Teammates.User

  require Sentinel.Repo

  def list_teammates(account_id) do
    User
    |> Bodyguard.scope(account_id)
    |> select_merge([u], %{full_name: fragment("CONCAT_WS(' ', last_name, first_name)")})
    |> Repo.all()
  end

  def get_teammate!(account_id, id) do
    Repo.one(from(u in User, where: u.id == ^id and u.account_id == ^account_id))
  end

  def get_teammate!(id) do
    Repo.get!(User, id)
  end

  def create_teammate(params) do
    Repo.tx do
      %User{}
      |> User.changeset(params)
      |> Repo.insert()
      |> case do
        {:ok, user} ->
          {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
          Repo.insert!(user_token)

          Events.create_event(:teammate_created, user, %{token: encoded_token})

        {:error, _changeset} = error ->
          error
      end
    end
  end

  @spec block_teammate(id :: integer) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def block_teammate(id) do
    from(u in User, where: u.id == ^id and u.state != ^:blocked)
    |> Repo.one!()
    |> Ecto.Changeset.change(%{state: :blocked})
    |> Repo.update()
  end

  def update_teammate(user, params) do
    user
    |> User.changeset(params)
    |> Repo.update!()
  end
end
