defmodule ImagerWeb.Plug.VerifyTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ImagerWeb.Plug.VerifyToken

  doctest VerifyToken

  describe "passthrough with defaults" do
    setup do
      opts = VerifyToken.init([])

      {:ok, opts: opts}
    end

    test "allows connection", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get()
        |> VerifyToken.call(opts)

      refute conn.halted
    end

    test "has assigned empty actions", %{opts: opts} do
      conn = 
        "/image.jpg"
        |> get()
        |> VerifyToken.call(opts)

      assert %{actions: []} = conn.assigns
    end
  end

  describe "actions with defaults" do
    setup do
      opts = VerifyToken.init([])

      {:ok, opts: opts}
    end

    test "allows connection", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get()
        |> VerifyToken.call(opts)

      refute conn.halted
    end

    test "has assigned actions list", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get(strip: true)
        |> VerifyToken.call(opts)

      assert %{actions: [{"strip", "true"}]} = conn.assigns
    end

    test "ignores token if present", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get(token: "foo")
        |> VerifyToken.call(opts)

      assert %{actions: []} = conn.assigns
    end
  end

  describe "passthrough with allowance and token" do
    setup do
      opts = VerifyToken.init(jwk: jwk("example"), allow_unsigned_passthrough: true)

      {:ok, opts: opts}
    end

    test "allows connection", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get()
        |> VerifyToken.call(opts)

      refute conn.halted
    end

    test "dissallow unsigned requests with actions", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get(strip: true)
        |> VerifyToken.call(opts)

      assert conn.halted
      assert {401, _, _} = sent_resp(conn)
    end

    test "ignores invalid token if present", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get(token: "foo")
        |> VerifyToken.call(opts)

      assert %{actions: []} = conn.assigns
    end
  end

  describe "passthrough without allowance and token" do
    setup do
      key = jwk("example")
      opts = VerifyToken.init(jwk: key, allow_unsigned_passthrough: false)

      {:ok, key: key, opts: opts}
    end

    test "disallows connections without token", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get(strip: true)
        |> VerifyToken.call(opts)

      assert conn.halted
      assert {401, _, _} = sent_resp(conn)
    end

    test "disallows connections with invalid path", %{key: key, opts: opts} do
      token = sign(key, "/invalid.jpg", "strip=true")
      conn =
        "/image.jpg"
        |> get(strip: true, token: token)
        |> VerifyToken.call(opts)

      assert conn.halted
      assert {401, _, _} = sent_resp(conn)
    end

    test "disallows connections with invalid actions", %{key: key, opts: opts} do
      token = sign(key, "/image.jpg", "thumbnail=120x120")
      conn =
        "/image.jpg"
        |> get(strip: true, token: token)
        |> VerifyToken.call(opts)

      assert conn.halted
      assert {401, _, _} = sent_resp(conn)
    end

    test "allows connections with valid token", %{key: key, opts: opts} do
      token = sign(key, "/image.jpg", "strip=true")
      conn =
        "/image.jpg"
        |> get(strip: true, token: token)
        |> VerifyToken.call(opts)

      refute conn.halted
    end

    test "fails with incorrect token", %{opts: opts} do
      conn =
        "/image.jpg"
        |> get(strip: true, token: "invalid")
        |> VerifyToken.call(opts)

      assert conn.halted
      assert {401, _, _} = sent_resp(conn)
    end

    test "fails with incorrect key", %{opts: opts} do
      token = sign(jwk("invalid"), "/image.jpg", "strip=true")
      conn =
        "/image.jpg"
        |> get(strip: true, token: token)
        |> VerifyToken.call(opts)

      assert conn.halted
      assert {401, _, _} = sent_resp(conn)
    end
  end

  defp get(path, query \\ []) do
    query =
      if query == [] do
        path
      else
        "#{path}?#{URI.encode_query(query)}"
      end

    conn(:get, query)
  end

  defp jwk(key) do
    JOSE.JWK.from(%{
      "kty" => "oct",
      "k" => Base.encode64(key)
    })
  end

  defp sign(key, path, query) do
    key
    |> JOSE.JWT.sign(%{"alg" => "HS256"}, %{"path" => path, "query" => query})
    |> JOSE.JWS.compact()
    |> elem(1)
  end
end
