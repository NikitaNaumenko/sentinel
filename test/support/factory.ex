defmodule Sentinel.Factory do
  use ExMachina.Ecto, repo: Sentinel.Repo
  use Sentinel.AccountsFactory
  use Sentinel.TeammatesFactory
end
