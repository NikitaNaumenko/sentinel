defmodule Sentinel.Teammates.UserPolicy do
  @moduledoc false
  @behaviour Bodyguard.Policy

  alias Sentinel.Accounts.User
  alias Sentinel.Teammates.User, as: Teammate

  # Admin users can do anything
  def authorize(:index, %User{role: :admin}, _), do: true
  def authorize(:create, %User{role: :admin}, _), do: true
  def authorize(:edit, %User{id: id, role: :admin}, %Teammate{id: id}), do: true

  def authorize(:block, %User{id: id}, %Teammate{id: id}), do: false
  def authorize(:block, %User{role: :admin}, %Teammate{state: :blocked}), do: false
  def authorize(:block, %User{role: :admin}, _), do: true

  def authorize(_, _, _), do: false
end
