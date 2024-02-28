defmodule Sentinel.Events.Recipient do
  @moduledoc """
  Custom type for events, it casts event type name to struct.
  """
  use Ecto.Type

  import Ecto.Query

  def type, do: :map

  def cast(%{id: id, type: type}) do
    result = Sentinel.Repo.one(from(r in String.to_existing_atom(type), where: r.id == ^id))

    {:ok, result}
  end

  def load(%{"id" => id, "type" => type}) do
    result = Sentinel.Repo.one(from(r in String.to_existing_atom(type), where: r.id == ^id))

    {:ok, result}
  end

  def dump(%{__struct__: type, id: id}) do
    {:ok, %{"id" => id, "type" => to_string(type)}}
  end
end
