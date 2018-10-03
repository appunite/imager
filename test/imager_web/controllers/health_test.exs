defmodule ImagerWeb.Controllers.HealthTest do
  use ImagerWeb.ConnCase, async: true

  test "returns 200 on existing file", %{conn: conn} do
    assert %{"status" => "pass"} = conn |> get("/health") |> json_response(200)
  end
end
