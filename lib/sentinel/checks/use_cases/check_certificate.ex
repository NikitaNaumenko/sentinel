defmodule Sentinel.Checks.UseCases.CheckCertificate do
  @moduledoc """
    Check ssl certificate and return map with info about expirations and issuer of certificate.
  """

  @spec call(String.t()) :: any()
  def call(url) do
    with {:ok, conn} <- Mint.HTTP.connect(:https, url, 443),
         {:ok, der} <- :ssl.peercert(conn.socket),
         {:ok, cert} <- X509.Certificate.from_der(der),
         {:Validity, not_before, not_after} <- X509.Certificate.validity(cert) do
      issuer_rdn = X509.Certificate.issuer(cert)
      subject_rdn = X509.Certificate.subject(cert)
      [issuer_common_name] = X509.RDNSequence.get_attr(issuer_rdn, :commonName)
      [subject_common_name] = X509.RDNSequence.get_attr(subject_rdn, :commonName)

      %{
        not_before: X509.DateTime.to_datetime(not_before),
        not_after: X509.DateTime.to_datetime(not_after),
        issuer: issuer_common_name,
        subject: subject_common_name
      }
    end
  end
end
