defmodule SentinelWeb.EnumHelpers do
  @moduledoc """
  Conveniences for translating and building enum selects.
  """

  use PhoenixHTMLHelpers

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
    |> append_empty_element(opts[:empty])
  end

  @doc """
  Generates a select with translated enum options.
  """
  def select_enum(form, field, module) do
    select(form, field, translated_select_enums(module, field))
  end

  defp append_empty_element(collection, nil), do: collection
  defp append_empty_element(collection, empty), do: [empty | collection]
end
