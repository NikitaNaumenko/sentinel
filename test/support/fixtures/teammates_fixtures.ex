defmodule Sentinel.TeammatesFixtures do
  @moduledoc false
  alias Sentinel.Repo
  alias Sentinel.Teammates
  alias Sentinel.Teammates.User

  def teammate_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{first_name: "John", last_name: "Doe", email: Faker.Internet.email()})

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  def blocked_teammate_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{first_name: "John", last_name: "Doe", email: Faker.Internet.email()})

    %User{state: :blocked}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end
end
