defmodule SentinelWeb.Components.Switch do
  @moduledoc false

  use Phoenix.Component

  attr :checked, :boolean, default: false
  attr :on_click, :any, required: true
  attr :label, :string, default: nil

  def switch(assigns) do
    ~H"""
    <label class="relative inline-flex cursor-pointer items-center" phx-click={@on_click}>
      <input type="checkbox" value="" class="peer sr-only" checked={@checked} />

      <div class="peer bg-input h-5 w-9 rounded-full after:content-[''] after:top-[2px] after:start-[2px] after:absolute after:h-4 after:w-4 after:rounded-full after:bg-white after:transition-all peer-checked:bg-primary peer-checked:after:translate-x-full peer-checked:after:border-white">
      </div>

      <span :if={@label} class="ms-3 text-sm font-medium text-gray-900">{@label}</span>
    </label>
    """
  end
end
