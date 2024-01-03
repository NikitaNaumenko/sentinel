defmodule Sentinel.Repo do
  use Ecto.Repo,
    otp_app: :sentinel,
    adapter: Ecto.Adapters.Postgres
end
