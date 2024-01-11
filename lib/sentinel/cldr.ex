defmodule Sentinel.Cldr do
  @moduledoc false
  use Cldr,
    otp_app: :sentinel,
    locales: ["en"],
    providers: [Cldr.DateTime, Cldr.Number, Cldr.Calendar]
end
