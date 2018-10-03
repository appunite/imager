defmodule ImagerWeb.Controllers.ImageTest do
  use ImagerWeb.ConnCase, async: true

  setup_all do
    Application.put_env(:imager, :stores, %{
      "test" => %{
        store: {Imager.Store.Dummy, dir: "test/fixtures/"},
        cache: {Imager.Store.Dummy, dir: "test/fixtures/"}
      }
    })
  end

  test "returns 200 on existing file", %{conn: conn} do
    assert conn |> get("/test/lenna.png") |> response(200)
  end

  test "returns 404 on non existing file", %{conn: conn} do
    assert conn |> get("/test/non-existent.png") |> response(404)
  end

  test "returns 404 on unknown store", %{conn: conn} do
    assert conn |> get("/unknown/lenna.png") |> response(404)
  end

  test "returns 404 on empty path", %{conn: conn} do
    assert conn |> get("/test/") |> response(404)
    assert conn |> get("/unknown/") |> response(404)
  end
end
