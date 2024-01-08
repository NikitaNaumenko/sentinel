defimpl Jason.Encoder, for: Finch.Response do
  def encode(%{body: body, headers: headers, status: status}, opts) do
    Jason.Encode.map(
      %{
        status: status,
        body: body,
        headers: Jason.OrderedObject.new(headers)
      },
      opts
    )
  end
end
