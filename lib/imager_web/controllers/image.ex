defmodule ImagerWeb.Controllers.Image do
  use Phoenix.Controller, namespace: ImagerWeb

  @moduledoc """
  API entrypoint for Imager.
  """

  import Plug.Conn
  import Mockery.Macro

  require Logger

  plug(ImagerWeb.Plug.VerifyToken)

  def get(%Plug.Conn{assigns: assigns} = conn, %{
        "store" => store,
        "path" => path
      })
      when length(path) > 0 do
    commands = Imager.Tool.from_query(assigns.actions)
    path = "/" <> Path.join(path)

    Logger.metadata(path: path, commands: inspect(commands))

    with {:ok, store} <- imager().store(store),
         {:ok, {size, mime, stream}} <- imager().process(store, path, commands) do
      conn =
        conn
        |> put_resp_content_type(mime, nil)
        |> put_resp_content_length(size)
        |> send_chunked(200)

      Enum.reduce_while(stream, conn, fn chunk, conn ->
        case chunk(conn, chunk) do
          {:ok, conn} -> {:cont, conn}
          {:error, :closed} -> {:halt, conn}
        end
      end)
    else
      :failed ->
        send_resp(conn, 412, "")

      _ ->
        send_resp(conn, 404, "")
    end
  end

  def get(conn, _), do: send_resp(conn, 404, "")

  defp imager, do: mockable(Imager)

  defp put_resp_content_length(conn, :unknown), do: conn

  defp put_resp_content_length(conn, size) when is_integer(size),
    do: put_resp_header(conn, "content-length", Integer.to_string(size))
end
