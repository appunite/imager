defmodule Imager.JOSE.Jason do
  @behaviour :jose_json

  def encode(data), do: Jason.encode!(data)

  def decode(data), do: Jason.decode!(data)
end
