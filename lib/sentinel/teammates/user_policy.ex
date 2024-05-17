defmodule Sentinel.Teammates.UserPolicy do
  @moduledoc false
  @behaviour Bodyguard.Policy

  alias Sentinel.Accounts.User

  # Admin users can do anything
  def authorize(:index, %User{role: :admin}, _), do: true
  def authorize(:create, %User{role: :admin}, _), do: true
  def authorize(:edit, %User{role: :admin}, _), do: true
  def authorize(_, _, _), do: false
end
