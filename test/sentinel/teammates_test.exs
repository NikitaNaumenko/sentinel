defmodule Sentinel.TeammatesTest do
  use Sentinel.DataCase

  import Sentinel.AccountsFixtures
  import Sentinel.TeammatesFixtures

  alias Sentinel.Teammates
  alias Sentinel.Teammates.User

  setup do
    account = account_fixture()
    %{account: account}
  end
  describe "list_teammates/1" do
    test "returns all teammates for a given account", %{account: account} do
      user1 = teammate_fixture(%{account_id: account.id})
      user2 = teammate_fixture(%{account_id: account.id})
      # account_id = 1
      # user1 = %User{id: 1, account_id: account_id, first_name: "John", last_name: "Doe"}
      # user2 = %User{id: 2, account_id: account_id, first_name: "Jane", last_name: "Smith"}
      # Repo.insert!(user1)
      # Repo.insert!(user2)
      #
      result = Teammates.list_teammates(account.id)

      assert length(result) == 2
      # assert Enum.any?(result, fn u -> u.full_name == "Doe John" end)
      # assert Enum.any?(result, fn u -> u.full_name == "Smith Jane" end)
    end
  end

  # describe "get_teammate!/2" do
  #   test "returns the teammate with the given id and account_id" do
  #     account_id = 1
  #     user = %User{id: 1, account_id: account_id, first_name: "John", last_name: "Doe"}
  #     Repo.insert!(user)
  #
  #     result = Teammates.get_teammate!(account_id, user.id)
  #
  #     assert result.id == user.id
  #     assert result.account_id == account_id
  #   end
  # end

  # describe "create_teammate/1" do
  #   test "creates a new teammate and triggers an event" do
  #     params = %{first_name: "John", last_name: "Doe", email: "john.doe@example.com"}
  #     assert {:ok, _} = Teammates.create_teammate(params)
  #
  #     user = Repo.get_by(User, email: "john.doe@example.com")
  #     assert user
  #   end
  # end

  # describe "update_teammate/2" do
  #   test "updates the teammate with the given params" do
  #     user = %User{id: 1, account_id: 1, first_name: "John", last_name: "Doe"}
  #     Repo.insert!(user)
  #     params = %{first_name: "Johnny"}
  #
  #     assert {:ok, _} = Teammates.update_teammate(user, params)
  #
  #     updated_user = Repo.get(User, user.id)
  #     assert updated_user.first_name == "Johnny"
  #   end
  # end
end
