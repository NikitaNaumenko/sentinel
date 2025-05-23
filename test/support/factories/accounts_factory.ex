defmodule Sentinel.AccountsFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      require ExUnitProperties

      def account_factory do
        %Sentinel.Accounts.Account{
          name: Faker.Name.name()
        }
      end
    end
  end
end
