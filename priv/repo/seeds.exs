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

alias Sentinel.Accounts
alias Sentinel.Monitors
alias Sentinel.StatusPages

Faker.start()

Sentinel.Repo.transaction(fn ->
  account = Sentinel.Repo.insert!(%Accounts.Account{name: "Account 1"})

  Sentinel.Repo.insert!(%Accounts.User{
    email: "full@mail.com",
    hashed_password: Bcrypt.hash_pwd_salt("password"),
    role: :admin,
    account_id: account.id
  })

  monitor =
    Sentinel.Repo.insert!(%Monitors.Monitor{
      name: "Monitor 1",
      url: "http://example.com",
      interval: 10,
      http_method: :get,
      request_timeout: 10,
      expected_status_code: 203,
      account_id: account.id
    })

  Sentinel.Repo.insert!(%Monitors.NotificationRule{
    monitor_id: monitor.id
  })

  # Sentinel.Repo.insert!(%Monitors.Monitor{
  #   name: "Monitor 2",
  #   url: "http://example.com",
  #   interval: 15,
  #   http_method: :get,
  #   request_timeout: 10,
  #   expected_status_code: 220,
  #   account_id: account.id
  # })
  #
  # Sentinel.Repo.insert!(%Monitors.Monitor{
  #   name: "Monitor 3",
  #   url: "http://example.com",
  #   interval: 20,
  #   http_method: :get,
  #   request_timeout: 10,
  #   expected_status_code: 200,
  #   account_id: account.id
  # })

  # Sentinel.Repo.insert!(%StatusPages.Page{
  #   name: "Status page",
  #   slug: "status-page",
  #   state: :published,
  #   public: true,
  #   account_id: account.id,
  #     monitor_id: monitor.id
  # })

  # Sentinel.Repo.insert!(%StatusPages.Page{
  #   name: "Other Status page",
  #   slug: "other-status-page",
  #   state: :draft,
  #   public: false,
  #   account_id: account.id
  # })
end)

[account] = Sentinel.Repo.all(Sentinel.Accounts.Account)

[1]
|> Stream.cycle()
|> Enum.take(15)
|> Enum.map(fn _ ->
  Sentinel.Repo.insert!(%Sentinel.Teammates.User{
    account_id: account.id,
    email: Faker.Internet.email(),
    hashed_password: Bcrypt.hash_pwd_salt("password"),
    role: Enum.random(Ecto.Enum.values(Sentinel.Teammates.User, :role)),
    state: Enum.random(Ecto.Enum.values(Sentinel.Teammates.User, :state))
  })
end)
