defmodule Sentinel.Events.Recipient do
  @moduledoc """
  Custom type for events, it casts event type name to struct.
  """
  use Ecto.Type

  import Ecto.Query

  def type, do: :map

  def cast(term), do: {:ok, term}
  # def cast(%{"id" => id, "type" => type}) do
  #   result = Sentinel.Repo.one(from(r in String.to_existing_atom(type), where: r.id == ^id))
  #
  #   {:ok, result}
  # end
  #
  # def cast(_), do: :error

  def load(%{"id" => id, "type" => type}) do
    result = Sentinel.Repo.one(from(r in String.to_existing_atom(type), where: r.id == ^id))

    {:ok, result}
  end

  def dump(item) do
    dbg(item)
    {:ok, %{id: item.id, type: item.type}}
  end

  def dump(%{__struct__: type, id: id}), do: {:ok, %{id: id, type: type}}
  def dump(_), do: :error

  # defp dispatch_to_struct(type) do
  #   "Elixir.Sentinel.Events.EventTypes.#{Recase.to_pascal(type)}"
  #   |> String.to_existing_atom()
  #   |> struct!()
  # end
end
