defmodule ImagerTest do
  use ExUnit.Case, async: true

  import Mockery

  setup do
    mock(Imager.Runner, :stream, {self(), []})
    mock(Imager.Runner, :feed_stream, :ok)
    mock(Imager.Runner, :wait, :ok)

    [
      store: %{
        store: {Imager.Store.Dummy, dir: "test/fixtures/"},
        cache: {Imager.Store.Dummy, dir: "test/fixtures/"}
      }
    ]
  end

  test "processing without commands returns file as is", %{store: store} do
    ref = make_ref()

    assert {:ok, {_size, "image/png", _stream}} =
             Imager.process(store, "/lenna.png", [], ref: ref)

    assert_received {:retrieved, ^ref, "/lenna.png"}
    refute_received {:missed, ^ref, "/lenna.png"}
    refute_received {:store, ^ref, "/lenna.png", _}
  end

  test "when providing command, there should be miss", %{store: store} do
    ref = make_ref()

    assert {:ok, {_size, _mime, _stream}} =
             Imager.process(store, "/lenna.png", [strip: true], ref: ref)

    assert_received {:missed, ^ref, _}
  end

  test "when provided command then there should be store call on non existent images",
       %{store: store} do
    ref = make_ref()

    assert {:ok, {_size, _mime, stream}} =
             Imager.process(store, "/lenna.png", [strip: true], ref: ref)

    assert_received {:store, ^ref, _, _}
  end

  test "when exist cached image, then there should be no store", %{
    store: store
  } do
    ref = make_ref()

    assert {:ok, {_size, _mime, stream}} =
             Imager.process(store, "/lenna.png", [flatten: true], ref: ref)

    assert_received {:retrieved, ^ref, "/lenna_flatten.png"}
    refute_received {:store, ^ref, "/lenna_flatten.png", _}
  end

  test "when processor fails, then there should be no store", %{store: store} do
    ref = make_ref()
    mock(Imager.Runner, :wait, :error)

    assert :failed =
             Imager.process(store, "/lenna.png", [strip: true], ref: ref)

    assert_received {:retrieved, ^ref, "/lenna.png"}
    refute_received {:store, ^ref, "/lenna_strip.png", _}
  end

  test "returns error on non-existent file", %{store: store} do
    assert :error = Imager.process(store, "/non-existent.png", flatten: true)
  end

  describe "store" do
    setup do
      Application.put_env(:imager, :stores, %{
        "test" => %{
          cache: {:foo, []},
          store: {:foo, []}
        }
      })

      on_exit(fn -> Application.delete_env(:imager, :stores) end)
    end

    test "returns store when exists" do
      assert {:ok, _} = Imager.store("test")
    end

    test "returns error when store not exists" do
      assert :error = Imager.store("not-exist")
    end

    test "store returns error when app env not set" do
      Application.delete_env(:imager, :stores)

      assert :error = Imager.store("not-exist")
    end
  end
end
