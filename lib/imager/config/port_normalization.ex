defmodule Imager.Config.PortNormalization do
  @moduledoc """
  Normalize port values to integers
  """

  def transform(:port, value) when is_binary(value) do
    num = String.to_integer(value)

    if num > 0 do
      num
    else
      raise "Expected port to be positive integer, got: #{inspect(value)}"
    end
  rescue
    ArgumentError ->
      reraise "Expected port to be positive integer, got: #{inspect(value)}",
              __STACKTRACE__
  end

  def transform(:port, value) when value > 0, do: value

  def transform(:port, value),
    do: raise("Expected port to be positive integer, got: #{inspect(value)}")

  def transform(_, value), do: value
end
