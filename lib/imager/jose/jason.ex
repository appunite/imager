defmodule Imager.JOSE.Jason do
  @moduledoc """
  Implement `:jose_json` behaviour for `Jason`
  """

  @behaviour :jose_json

  def encode(data), do: Jason.encode!(data)

  def decode(data), do: Jason.decode!(data)
end
