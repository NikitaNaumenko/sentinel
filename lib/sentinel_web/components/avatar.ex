defmodule SentinelWeb.Components.Avatar do
  @moduledoc """
  Defines the `Carbon.Avatar` component for the Phoenix framework.

  This component is used for displaying an avatar image in a web application. It is highly customizable, allowing the specification of the avatar's size and a fallback option if the image is not available. The avatar can adapt to different contexts and UI requirements.

  ## Features

  - Customizable size with predefined variants (small, medium, large).
  - Supports a fallback text or symbol if the image is not provided.
  - Rounded and fully responsive for consistent integration into various layouts.

  ## Usage

  The `Carbon.Avatar` component can be used in user interfaces where a visual representation of a user or entity is required, such as user profiles, comments sections, or chat interfaces.
  """
  use Phoenix.Component
  use CVA.Component

  attr :image, :string, default: nil
  attr :fallback, :string, default: ""

  variant(
    :size,
    [
      sm: "h-10 w-10",
      md: "h-12 w-12",
      lg: "h-16 w-16"
    ],
    default: :md
  )

  @doc """
    Renders the `Carbon.Avatar` component.

  Creates an avatar image, with an option for a fallback text or symbol if the image source is not provided. The size of the avatar can be controlled through the `size` variant. This function generates a rounded avatar that adapts responsively to the layout.

  ## Options

    - `:image` - The source URL of the avatar image.
    - `:fallback` - Fallback text or symbol to display if the image is not available.
    - `:size` - The size of the avatar (small, medium, large).
  """
  def avatar(assigns) do
    ~H"""
    <span class={["relative flex shrink-0 overflow-hidden rounded-full", @cva_class]}>
      <%= if @image do %>
        <img src={@image} class="h-full w-full rounded-full" />
      <% else %>
        <span class="bg-muted flex h-full w-full items-center justify-center rounded-full">
          <%= @fallback %>
        </span>
      <% end %>
    </span>
    """
  end
end
