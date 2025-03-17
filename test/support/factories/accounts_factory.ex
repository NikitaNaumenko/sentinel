defmodule Sentinel.AccountsFactory do
  defmacro __using__(_opts) do
    quote do
      require ExUnitProperties

      def account_factory do
        %Sentinel.Accounts.Account{
          name: "My awesome article!",
        }
      end
    end
  end
end
