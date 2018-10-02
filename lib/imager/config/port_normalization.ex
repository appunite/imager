defmodule Imager.Config.PortNormalization do
  @moduledoc """
  Normalize port values to integers
  """

  def transform(:port, value) when is_binary(value), do: String.to_integer(value)
  def transform(:port, value) when is_integer(value), do: value
  def transform(_, value), do: value
end
