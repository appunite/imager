defmodule Imager.Store.LocalTest do
  use ExUnit.Case, async: true

  @fixtures "test/fixtures"

  alias Imager.Store.Local, as: Subject

  describe "retrieve" do
    test "existing file" do
      assert {:ok, {_, "image/png", _}} = Subject.retrieve("lenna.png", dir: @fixtures)
    end

    test "existing file without extension" do
      assert {:ok, {_, "application/octet-stream", _}} = Subject.retrieve("file-without-ext", dir: @fixtures)
    end

    test "non-existing file" do
      assert :error = Subject.retrieve("non-existing.png", dir: @fixtures)
    end
  end

  describe "store" do
    setup do
      dir = Temp.path!()

      on_exit fn -> File.rm_rf!(dir) end

      [dir: dir]
    end

    test "creates directory if not exists", %{dir: dir} do
      refute File.exists?(dir)

      _ = Subject.store("foo", "text/plain", ["foo\n"], dir: dir) |> Stream.run()

      assert File.dir?(dir)
    end

    test "stores given file", %{dir: dir} do
      _ = Subject.store("foo", "text/plain", ["foo\n"], dir: dir) |> Stream.run()
      path = Path.join(dir, "foo")

      assert File.exists?(path)
      assert "foo\n" == File.read!(path)
    end
  end
end
