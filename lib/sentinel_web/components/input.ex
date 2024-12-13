defmodule SentinelWeb.Components.Input do
  @moduledoc false
  use Phoenix.Component

  import SentinelWeb.Components.Label

  alias Phoenix.HTML.Form
  alias Phoenix.HTML.FormField

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label class={["flex items-center gap-2 text-sm leading-6", @errors != [] && "text-danger"]}>
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="border-primary text-primary rounded focus:ring-0"
          {@rest}
        />
        {@label}
      </.label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label :if={@label} for={@id}>{@label}</.label>
      <select id={@id} name={@name} class="form-select" multiple={@multiple} {@rest}>
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label :if={@label} class={@errors != [] && "text-danger"} for={@id}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        class={["min-h-[60px] border-input flex w-full rounded-md border bg-transparent px-3 py-2 text-sm shadow-sm placeholder:text-muted-foreground focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:cursor-not-allowed disabled:opacity-50"]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "radio_group"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2 space-y-1" phx-feedback-for={@name}>
      <div :for={{label, value} <- @options} class="flex items-center space-x-3 space-y-0">
        <.input name={@name} value={value} checked={} type="radio" />
        <.label
          for={@name}
          class="text-sm leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 font-normal"
        >
          {label}
        </.label>
      </div>
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <input
      id={"#{@id}_#{@value}"}
      type="radio"
      value={@value}
      checked={@checked}
      name={@name}
      class="aspect-square border-primary text-primary ring-offset-background h-4 w-4 rounded-full border focus:ring-primary focus:outline-none focus-visible:ring-ring focus-visible:ring-1 focus-visible:ring-offset-1 disabled:cursor-not-allowed disabled:opacity-50"
    />
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label :if={@label} class={@errors != [] && "text-danger"} for={@id}>{@label}</.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={["form-control"]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="text-danger mt-1 flex gap-3 text-sm leading-6 phx-no-feedback:hidden">
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(SentinelWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(SentinelWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
