defmodule Sentinel.TeammatesTest do
  use Sentinel.DataCase

  # import Sentinel.AccountsFixtures, only: [account_fixture: 0]
  # import Sentinel.TeammatesFixtures

  alias Sentinel.Teammates
  alias Sentinel.Teammates.User

  setup do
    account = insert(:account)
    %{account: account}
  end

  describe "list_users/1" do
    test "returns all users for a given account", %{account: account} do
      insert_list(5, :user, account_id: account.id)

      account2 = insert(:account)
      insert_list(5, :user, account_id: account2.id)

      result = Teammates.list_users(account.id)

      assert length(result) == 5
    end
  end

  describe "block_user/1" do
    test "blocks an active user", %{account: account} do
      user = insert(:user, account: account)

      assert {:ok, %User{state: :blocked}} = Teammates.block_user(user.id)
    end

    test "raises error when blocking an already blocked user", %{account: account} do
      user = insert(:user, account: account, state: :blocked)

      assert_raise Ecto.NoResultsError, fn ->
        Teammates.block_user(user.id)
      end
    end
  end

  describe "get_teammate!/2" do
    test "returns the teammate with the given id and account_id", %{account: account} do
      %User{id: user_id, account_id: account_id} = insert(:user, account: account)
      assert %User{id: ^user_id} = Teammates.get_user(account_id, user_id)
    end
  end

  describe "create_teammate/1" do
    test "creates a new teammate and triggers an event", %{account: account} do
      params = params_for(:user, account: account)
      assert {:ok, user} = Teammates.create_user(params)

      assert_enqueued(worker: Sentinel.Events.CollectEventAcceptor)

      assert ^user = Teammates.get_user(account.id, user.id)
    end
  end
end
