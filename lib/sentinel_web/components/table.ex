defmodule SentinelWeb.Components.Table do
  @moduledoc false

  use Phoenix.Component

  import SentinelWeb.Gettext

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:row_id, :any, default: nil, doc: "the function for generating the row id")
  attr(:row_click, :any, default: nil, doc: "the function for handling phx-click on each row")

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  slot :col, required: true do
    attr(:label, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="relative w-full overflow-auto">
      <table class="caption-bottom w-full text-sm">
        <thead class="[&_tr]:border-b">
          <tr class="border-b transition-colors hover:bg-muted/50">
            <th
              :for={col <- @col}
              class="text-muted-foreground w-[100px] h-12 px-4 text-left align-middle [&:has([role=checkbox])]:pr-0"
            >
              <%= col[:label] %>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="[&_tr:last-child]:border-0"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="border-b transition-colors hover:bg-muted/50"
          >
            <td
              :for={{col, _i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["p-4 align-middle [&:has([role=checkbox])]:pr-0", @row_click && "hover:cursor-pointer"]}
            >
              <%= render_slot(col, @row_item.(row)) %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
