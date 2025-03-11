defmodule Sentinel.TeammatesFixtures do
  alias Sentinel.Teammates
  alias Sentinel.Accounts.User
  alias Sentinel.Repo

  def teammate_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        first_name: "John",
        last_name: "Doe",
        email: "john.doe@example.com",
      })
      |> Teammates.create_teammate()

    user
  end
end

