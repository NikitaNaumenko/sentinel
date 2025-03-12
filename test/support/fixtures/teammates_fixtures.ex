defmodule Sentinel.TeammatesFixtures do
  @moduledoc false
  alias Sentinel.Accounts.User
  alias Sentinel.Repo
  alias Sentinel.Teammates

  def teammate_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        first_name: "John",
        last_name: "Doe",
        email: "john.doe@example.com"
      })
      |> Teammates.create_teammate()

    user
  end
end
