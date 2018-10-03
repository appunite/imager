defmodule Imager.Config.PortNormalizationTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Imager.Config.PortNormalization, as: Subject

  defp non_positive_integer do
    gen all value <- one_of([positive_integer(), constant(0)]), do: -value
  end

  defp assert_fail(value) do
    assert_raise RuntimeError,
                 "Expected port to be positive integer, got: #{inspect(value)}",
                 fn ->
                   Subject.transform(:port, value)
                 end
  end

  property "port values of positive integer are passed through" do
    check all value <- positive_integer() do
      assert value == Subject.transform(:port, value)
    end
  end

  property "port values of strings representing positive integers are passed through" do
    check all num <- positive_integer(),
              value = Integer.to_string(num) do
      assert num == Subject.transform(:port, value)
    end
  end

  property "raises error for non-positive integers" do
    check all value <- non_positive_integer() do
      assert_fail(value)
    end
  end

  property "raises error for strings containing non-positive integers" do
    check all num <- non_positive_integer(),
              value = Integer.to_string(num) do
      assert_fail(value)
    end
  end

  property "raises error for strings not containing numbers" do
    check all number <- string(?0..?9),
              alphas <- string(?a..?z, min_length: 1) do
      assert_fail(alphas <> number)
      assert_fail(number <> alphas)
      assert_fail(alphas)
    end
  end

  property "all non-port fields are passed through" do
    check all key <- atom(:alphanumeric),
              key != :port,
              value <- term() do
      assert value == Subject.transform(key, value)
    end
  end
end
