defmodule Sentinel.FakeCheckCertificate do
  @moduledoc  """
  Provides fake certificate check. Instead real certificate check it returns fake data.
  """
  def call(_) do
    %{
      "not_before" => DateTime.utc_now(),
      "not_after" => DateTime.utc_now(),
      "issuer" => "test",
      "subject" => "jopa"
    }
  end
end
