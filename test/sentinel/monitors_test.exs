defmodule Sentinel.MonitorsTest do
  use Sentinel.DataCase
  use Repatch.ExUnit

  import Sentinel.AccountsFixtures

  alias Sentinel.Monitors

  setup do
    account = account_fixture()
    %{account: account}
  end

  describe "create_monitors_from_file/2" do
    test "create from json", %{account: account} do
      Repatch.patch(Sentinel.Monitors.UseCases.CheckCertificate, :call, fn _ ->
        %{
        "not_before" => DateTime.utc_now(),
        "not_after" => DateTime.utc_now(),
        "issuer" => "test",
        "subject" => "jopa"

        }
      end)

      json_filepath = "test/support/fixtures/files/monitors.json"
      assert Enum.count(Monitors.list_monitors(account.id)) == 0
      assert {:ok, monitors} = Monitors.create_monitors_from_file(json_filepath, account.id)
      assert Enum.count(Monitors.list_monitors(account.id)) == 5
    end
  end
end
