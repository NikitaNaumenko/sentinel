defmodule Sentinel.Teammates do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Sentinel.Events
  alias Sentinel.Repo
  alias Sentinel.Teammates.User

  def list_teammates(account_id) do
    User
    |> where([u], u.account_id == ^account_id)
    |> select_merge([u], %{full_name: fragment("CONCAT_WS(' ', last_name, first_name)")})
    |> Repo.all()
  end

  def get_teammate!(id) do
    Repo.get!(User, id)
  end

  def create_teammate(params) do
    Repo.transaction(fn ->
      user =
        %User{}
        |> User.changeset(params)
        |> Repo.insert()

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      Events.create_event(:teammate_created, user, %{token: token})
    end)
  end
end
