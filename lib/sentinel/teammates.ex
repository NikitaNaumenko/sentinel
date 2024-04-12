defmodule Sentinel.Teammates do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Sentinel.Teammates.User
  alias Sentinel.Repo

  def list_teammates(account_id) do
    User
    |> where([u], u.account_id == ^account_id)
    |> select_merge([u], %{full_name: fragment("CONCAT_WS(' ', last_name, first_name)")})
    |> Repo.all()
  end

  def create_teammate(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end
end
