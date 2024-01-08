defimpl Jason.Encoder, for: [Finch.Response] do
  def encode(struct, opts) do
    Jason.Encode.list(Enum.to_list(struct), opts)
  end
end
