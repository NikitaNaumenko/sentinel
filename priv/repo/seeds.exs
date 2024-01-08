# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sentinel.Repo.insert!(%Sentinel.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
alias Sentinel.Accounts
alias Sentinel.Checks

Sentinel.Repo.transaction(fn ->
  account = Sentinel.Repo.insert!(%Accounts.Account{name: "Account 1"})

  user =
    Sentinel.Repo.insert!(%Accounts.User{
      email: "full@mail.com",
      hashed_password: Bcrypt.hash_pwd_salt("password"),
      account_id: account.id
    })

  Sentinel.Repo.insert!(%Checks.Monitor{
    name: "Monitor 1",
    url: "http://example.com",
    interval: 10,
    http_method: :get,
    request_timeout: 10,
    expected_status_code: 203,
    account_id: account.id
  })

  Sentinel.Repo.insert!(%Checks.Monitor{
    name: "Monitor 2",
    url: "http://example.com",
    interval: 15,
    http_method: :get,
    request_timeout: 10,
    expected_status_code: 220,
    account_id: account.id
  })

  Sentinel.Repo.insert!(%Checks.Monitor{
    name: "Monitor 3",
    url: "http://example.com",
    interval: 20,
    http_method: :get,
    request_timeout: 10,
    expected_status_code: 200,
    account_id: account.id
  })
end)
