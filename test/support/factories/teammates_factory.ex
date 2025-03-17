defmodule Sentinel.TeammatesFactory do
  @moduledoc false
  alias Telegram.Bot

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Sentinel.Teammates.User{
          email: sequence(:email, &"user#{&1}@example.com"),
          first_name: sequence(:first_name, &"FirstName#{&1}"),
          last_name: sequence(:last_name, &"LastName#{&1}"),
          hashed_password: Bcrypt.hash_pwd_salt("password"),
          state: :active,
          role: :user
        }
      end
    end
  end
end
