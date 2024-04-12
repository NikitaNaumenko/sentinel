defmodule SentinelWeb.FormHelpers do
  @moduledoc """
    Collection of  helpers for forms, inputs, submit etc.
  """
  use PhoenixHTMLHelpers

  def collection_for_select(collection, {key, value}, opts \\ []) do
    collection
    |> Enum.map(fn element ->
      map = Map.from_struct(element)
      {get_in(map, List.wrap(value)), Map.fetch!(map, key)}
    end)
    |> append_empty(opts[:empty])
  end

  @doc """
  Translates an enum value using gettext.
  """
  def translate_enum(value) when is_atom(value) do
    value =
      value
      |> Atom.to_string()
      |> humanize()

    Gettext.dgettext(SentinelWeb.Gettext, "enums", value)
  end

  def translate_enum(value) do
    value = humanize(value)

    Gettext.dgettext(SentinelWeb.Gettext, "enums", value)
  end

  @doc """
  Returns all translated enum values for the select options.
  """
  def translated_select_enums(module, field, opts \\ []) do
    module
    |> Ecto.Enum.values(field)
    |> Enum.map(fn value -> {translate_enum(value), value} end)
    |> append_empty(opts[:empty])
  end

  @doc """
  Generates a select with translated enum options.
  """
  def select_enum(form, field, module) do
    select(form, field, translated_select_enums(module, field))
  end

  defp append_empty(col, nil), do: col
  defp append_empty(col, empty), do: [empty | col]
end
