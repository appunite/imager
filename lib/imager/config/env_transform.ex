defmodule Imager.Config.EnvTransform do
  @moduledoc """
  Transform values that uses environment variables to provided values
  """

  @behaviour Toml.Transform

  def transform(_, "$" <> env_name), do: System.get_env(env_name)
  def transform(_, value), do: value
end
