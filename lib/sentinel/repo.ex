defmodule Sentinel.Repo do
  use Ecto.Repo,
    otp_app: :sentinel,
    adapter: Ecto.Adapters.Postgres

  defmacro tx(do: block) do
    quote location: :keep, generated: true do
      unquote(__MODULE__).transaction(fn ->
        case unquote(block) do
          {:error, err} -> unquote(__MODULE__).rollback(err)
          {:ok, result} -> result
          result -> result
        end
      end)
    end
  end
end
