defmodule SentinelWeb.Components.Icon do
  @moduledoc false

  use Phoenix.Component

  attr :name, :string, required: true
  attr :class, :string, default: nil

  @doc """
  A dynamic way of generating an icon

  Example:

      <.icon name="icon-arrow-right" class="w-5 h-5" />
  """
  def icon(assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
