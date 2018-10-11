defmodule ImagerWeb.Controllers.ImageTest do
  use ImagerWeb.ConnCase, async: true

  import Mockery

  @content <<1, 2, 3, 4, 5>>

  setup do
    mock(Imager, [store: 1], fn
      "test" ->
        {:ok,
         %{
           store: {Imager.Store.Blackhole, []},
           cache: {Imager.Store.Blackhole, []}
         }}

      _ ->
        :error
    end)

    :ok
  end

  describe "file exists and has known size" do
    setup do
      mock(Imager, :process, {:ok, {5, "foo/bar", [@content]}})

      :ok
    end

    test "returns 200", %{conn: conn} do
      assert @content == conn |> get("/test/lenna.png") |> response(200)
    end

    test "has Content-Length header", %{conn: conn} do
      conn = get(conn, "/test/lenna.png")

      assert ["5"] == get_resp_header(conn, "content-length")
    end

    test "has Content-Type header", %{conn: conn} do
      conn = get(conn, "/test/lenna.png")

      assert ["foo/bar"] == get_resp_header(conn, "content-type")
    end
  end

  describe "file exists and has unknown size" do
    setup do
      mock(Imager, :process, {:ok, {:unknown, "foo/baz", [@content]}})

      :ok
    end

    test "returns 200", %{conn: conn} do
      assert @content == conn |> get("/test/lenna.png") |> response(200)
    end

    test "has no Content-Length header", %{conn: conn} do
      conn = get(conn, "/test/lenna.png")

      assert [] == get_resp_header(conn, "content-length")
    end

    test "has Content-Type header", %{conn: conn} do
      conn = get(conn, "/test/lenna.png")

      assert ["foo/baz"] == get_resp_header(conn, "content-type")
    end
  end

  describe "file doesn't exist" do
    setup do
      mock(Imager, :process, :error)

      :ok
    end

    test "returns 404", %{conn: conn} do
      assert conn |> get("/test/non-existent.png") |> response(404)
    end
  end

  describe "file processor failed" do
    setup do
      mock(Imager, :process, :failed)

      :ok
    end

    test "returns 412", %{conn: conn} do
      assert conn |> get("/test/non-existent.png") |> response(412)
    end
  end

  test "returns 404 on unknown store", %{conn: conn} do
    assert conn |> get("/unknown/lenna.png") |> response(404)
  end

  test "returns 404 on empty path", %{conn: conn} do
    assert conn |> get("/test/") |> response(404)
    assert conn |> get("/unknown/") |> response(404)
  end
end
