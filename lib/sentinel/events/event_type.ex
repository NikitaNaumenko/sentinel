defmodule Ubr.Events.EventType do
  @moduledoc """
  Custom type for events, it casts event type name to struct.
  """
  use Ecto.Type

  def type, do: :string

  @event_types ~w[
    admin_signed_in
    admin_failed_sign_in
    admin_first_signed_in
    user_signed_in
    user_failed_sign_in
    user_first_signed_in
    otp_verified
    otp_verification_failed
    otp_sent
  ]

  def cast(type) when type in @event_types do
    type_struct = dispatch_to_struct(type)

    {:ok, type_struct}
  end

  def cast(_), do: :error

  def load(type) do
    type_struct = dispatch_to_struct(type)
    {:ok, type_struct}
  end

  def dump(%{__struct__: _event_type_struct, type: type}), do: {:ok, type}
  def dump(_), do: :error

  defp dispatch_to_struct(type) do
    "Elixir.Sentinel.Events.EventTypes.#{Recase.to_pascal(type)}"
    |> String.to_existing_atom()
    |> struct!()
  end
end
