defmodule ImagerWeb.Plug.VerifyToken do
  use Plug.Builder

  @moduledoc """
  Check if provided JWT signature is correct if needed.
  """

  require Logger

  import Plug.Conn, only: [halt: 1, assign: 3, send_resp: 3]

  plug(:verify_token)
  plug(:verify_unsigned_passthrough)

  def init(opts) do
    %{
      allow_unsigned_passthrough:
        Keyword.get_lazy(
          opts,
          :allow_unsigned_passthrough,
          &allow_unsigned_passthrough?/0
        ),
      jwk: Keyword.get_lazy(opts, :jwk, &jwk/0)
    }
  end

  def call(conn, opts) do
    params =
      conn.query_string
      |> URI.query_decoder()
      |> Enum.to_list()

    {token, actions} =
      case List.keytake(params, "token", 0) do
        {{"token", token}, actions} -> {token, actions}
        _ -> {nil, params}
      end

    conn
    |> assign(:actions, actions)
    |> handle(token, actions, opts)
  end

  defp handle(conn, _, _, %{jwk: nil}), do: conn
  defp handle(conn, _, [], %{allow_unsigned_passthrough: true}), do: conn

  defp handle(conn, token, actions, %{jwk: key}) when not is_nil(token) do
    actions_query = URI.encode_query(actions)

    with {true, jwt, _} <- JOSE.JWT.verify(key, token),
         fields = jwt.fields,
         {_, true} <- {:query, fields["query"] == actions_query},
         {_, true} <- {:path, fields["path"] == conn.request_path} do
      conn
    else
      {:error, _} -> disallow(conn, "Invalid token signature")
      {false, _, _} -> disallow(conn, "Invalid token signature")
      {type, false} -> disallow(conn, "Invalid value of field #{type}")
    end
  end

  defp handle(conn, _, _, _), do: disallow(conn, "Invalid request")

  defp disallow(conn, msg) do
    conn
    |> send_resp(:unauthorized, msg)
    |> halt()
  end

  defp allow_unsigned_passthrough?,
    do: Application.get_env(:imager, :allow_unsigned_passthrough, true)

  defp jwk do
    if key = Application.get_env(:imager, :secret_key) do
      JOSE.JWK.from(%{
        "kty" => "oct",
        "k" => Base.encode64(key)
      })
    end
  end
end
