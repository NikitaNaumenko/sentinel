defmodule Sentinel.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Sentinel.Repo
  use Sentinel.AccountsFactory
  use Sentinel.TeammatesFactory
end
