defmodule Imager.Config.EnvTransformTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Imager.Config.EnvTransform, as: Subject

  defp non_env() do
    gen all value <- term(),
      not match?("$" <> _, value),
      do: value
  end

  property "values not starting with `$` are passed as is" do
    check all key <- atom(:alphanumeric),
      value <- non_env() do
        assert value == Subject.transform(key, value)
      end
  end

  test "returns set value when there exists environment variable" do
    System.put_env("FOO", "foo")

    on_exit fn -> System.delete_env("FOO") end

    assert "foo" == Subject.transform(:foo, "$FOO")
  end

  test "returns nil when value is unset" do
    assert is_nil Subject.transform(:foo, "$NON_SET_ENV_VAR")
  end
end
