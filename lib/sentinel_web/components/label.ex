defmodule SentinelWeb.Components.Label do
  @moduledoc """
  A Phoenix component for rendering labels within the Sentinel application.

  This component is designed to enhance form accessibility and usability by providing
  a consistent styling and behavior for labels across the application. It leverages the Phoenix
  Component library to enable easy embedding within LiveView templates or other Phoenix components.

   ## Usage

  The component must be used with a provided `:inner_block` slot that contains the label's content.
  Custom classes can be added via the `:class` attribute, and the `for` attribute should be linked
  to the corresponding form input's `id` attribute for accessibility purposes.

  ### Example

      <%= label for: "user_email", class: "my-custom-class" do %>
        Email Address
      <% end %>

  This renders a label for an input field with an `id` of `user_email`, and applies
  custom styling alongside the default styles.
  """
  use Phoenix.Component

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={["text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 phx-no-feedback:text-primary", @class]}
    >
      <%= render_slot(@inner_block) %>
    </label>
    """
  end
end
