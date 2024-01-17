defmodule Sentinel.Carbon.Button do
  @moduledoc false
  use Phoenix.Component

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def bbutton(assigns) do
    ~H"""
    <button
      type={@type}
      class={["bg-primary text-primary-foreground h-10 px-4 py-2 hover:bg-primary/90", @class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
