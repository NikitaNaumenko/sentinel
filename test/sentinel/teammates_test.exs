defmodule Sentinel.TeammatesTest do
  use Sentinel.DataCase

  import Sentinel.AccountsFixtures, only: [account_fixture: 0]
  import Sentinel.TeammatesFixtures

  alias Sentinel.Teammates
  alias Sentinel.Teammates.User

  setup do
    account = account_fixture()
    %{account: account}
  end

  describe "list_users/1" do
    test "returns all users for a given account", %{account: account} do
      user1 = teammate_fixture(%{account_id: account.id})
      user2 = teammate_fixture(%{account_id: account.id})

      result = Teammates.list_users(account.id)

      assert length(result) == 2
    end
  end

  describe "block_user/1" do
    test "blocks an active user", %{account: account} do
      user = teammate_fixture(%{account_id: account.id})

      assert {:ok, %User{state: :blocked}} = Teammates.block_user(user.id)
    end

    test "raises error when blocking an already blocked user", %{account: account} do
      user = blocked_teammate_fixture(%{account_id: account.id})

      assert_raise Ecto.NoResultsError, fn ->
        dbg(Teammates.block_user(user.id))
      end
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
