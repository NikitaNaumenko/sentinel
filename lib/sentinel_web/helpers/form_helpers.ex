defmodule SentinelWeb.FormHelpers do
  @moduledoc """
    Collection of  helpers for forms, inputs, submit etc.
  """
  def collection_for_select(collection, {key, value}, opts \\ []) do
    collection
    |> Enum.map(fn element ->
      map = Map.from_struct(element)
      {get_in(map, List.wrap(value)), Map.fetch!(map, key)}
    end)
    |> append_empty(opts[:empty])
  end

  defp append_empty(col, nil), do: col
  defp append_empty(col, empty), do: [empty | col]
end
