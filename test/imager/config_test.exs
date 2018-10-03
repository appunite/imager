defmodule Imager.ConfigTest do
  use ExUnit.Case, async: true

  alias Imager.Config, as: Subject

  test "ignores non-existent files" do
    assert :ok = Subject.init(path: "non-existent-file.toml")
  end

  test "raises on missing path param" do
    assert_raise KeyError, fn ->
      Subject.init([])
    end
  end

  test "raises Toml.Error on invalid TOML" do
    assert_raise Toml.Error, fn ->
      Subject.init(path: "test/fixtures/incorrect.config.toml")
    end
  end

  test "sets config after successful run" do
    assert :ok = Subject.init(path: "test/fixtures/correct.config.toml")
    assert %{"test" => _} = Application.get_env(:imager, :stores)

    Application.delete_env(:imager, :stores)
  end

  test "merges config after successful run" do
    Application.put_env(:imager, :stores, %{"bar" => nil})

    assert :ok = Subject.init(path: "test/fixtures/correct.config.toml")
    assert %{"test" => _, "bar" => _} = Application.get_env(:imager, :stores)

    Application.delete_env(:imager, :stores)
  end
end
