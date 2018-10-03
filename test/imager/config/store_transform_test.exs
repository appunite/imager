defmodule Imager.Config.StoreTransformTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Imager.Config.StoreTransform, as: Subject

  defp type(types \\ ~w(S3 Local Blackhole)),
    do: one_of(Enum.map(types, &constant/1))

  defp store_config(typ \\ type(), options \\ constant(%{})) do
    fixed_map(%{type: typ, options: options})
  end

  property "returns map with stringified atoms" do
    check all path <- atom(:alphanumeric),
      config <- store_config()
    do
      assert Map.has_key?(Subject.transform(:stores, %{path => config}), Atom.to_string(path))
    end
  end

  property "returns map with equal fields `store` and `cache`" do
    check all config <- store_config() do
      assert %{"foo" => result} = Subject.transform(:stores, %{foo: config})
      assert %{store: data, cache: data} = result
    end
  end

  property "returns map with different fields `store` and `cache` when both are defined" do
    check all [t1, t2] <- uniq_list_of(type(), length: 2),
      store <- store_config(constant(t1)),
      cache <- store_config(constant(t2))
    do
      assert %{"foo" => result} = Subject.transform(:stores, %{foo: %{store: store, cache: cache}})
      assert %{store: store_tuple, cache: cache_tuple} = result
      assert store_tuple != cache_tuple
    end
  end

  property "returns map with different fields `store` and `cache` when any is set" do
    check all [t1, t2] <- uniq_list_of(type(), length: 2),
      main <- store_config(constant(t1)),
      other <- store_config(constant(t2)),
      field <- one_of([constant(:cache), constant(:store)]),
      config = Map.put(main, field, other)
    do
      assert %{"foo" => result} = Subject.transform(:stores, %{foo: config})
      assert %{store: store_tuple, cache: cache_tuple} = result
      assert store_tuple != cache_tuple
    end
  end

  property "raises when there is unknown type" do
    check all typ <- string(:alphanumeric),
      typ not in ~w(S3 Local Blackhole),
      config <- store_config(constant(typ))
    do
      assert_raise RuntimeError, fn ->
        Subject.transform(:stores, %{foo: config})
      end
    end
  end

  property "raises when path contains slash" do
    check all a <- string([?a..?z]),
      b <- string([?a..?z]),
      path = a <> "/" <> b,
      config <- store_config()
    do
      assert_raise RuntimeError, "'#{path}' cannot contain '/'", fn ->
        Subject.transform(:stores, %{path => config})
      end
    end
  end

  test "raises when uses reserved name" do
    assert_raise RuntimeError, "'health' is reserved name", fn ->
      Subject.transform(:stores, %{health: %{type: "Blackhole"}})
    end
  end

  property "other values are passed through unchanged" do
    check all key <- atom(:alphanumeric),
      key != :stores,
      value <- term()
    do
      assert value == Subject.transform(key, value)
    end
  end
end
