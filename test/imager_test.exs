defmodule ImagerTest do
  use ExUnit.Case, async: true

  setup do
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

  @tag :exec
  test "when providing command, there should be miss", %{store: store} do
    ref = make_ref()

    assert {:ok, {_size, _mime, _stream}} =
             Imager.process(store, "/lenna.png", [strip: true], ref: ref)

    assert_received {:missed, ^ref, _}
  end

  @tag :exec
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

  test "returns error on non-existent file", %{store: store} do
    assert :error = Imager.process(store, "/non-existent.png", flatten: true)
  end
end
