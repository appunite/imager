defmodule Imager.Store.S3Test do
  use ExUnit.Case, async: true

  import Plug.Conn

  alias Imager.Store.S3, as: Subject

  @path "/foo"

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "retrieve" do
    test "returns :error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert :error = Subject.retrieve(@path, port: bypass.port)
    end

    test "returns :error on non-existent", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "HEAD"
        assert conn.request_path == @path

        resp(conn, 404, "")
      end)

      assert :error = Subject.retrieve(@path, port: bypass.port)
    end

    test "returns correct size and MIME", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "HEAD"
        assert conn.request_path == @path

        conn
        |> put_resp_header("content-length", "123456")
        |> put_resp_header("content-type", "foo/bar")
        |> send_chunked(200)
      end)

      assert {:ok, {123_456, "foo/bar", _}} =
               Subject.retrieve(@path, port: bypass.port)
    end

    test "returned stream fetches data from store", %{bypass: bypass} do
      Bypass.expect_once(bypass, "HEAD", @path, fn conn ->
        conn
        |> put_resp_header("content-length", "3")
        |> put_resp_header("content-type", "foo/bar")
        |> send_chunked(200)
      end)

      assert {:ok, {3, "foo/bar", stream}} =
               Subject.retrieve(@path, port: bypass.port)

      Bypass.expect_once(bypass, "GET", @path, fn conn ->
        assert get_req_header(conn, "range") == ["bytes=0-2"]

        resp(conn, 200, "foo")
      end)

      assert ["foo"] == Enum.to_list(stream)
    end

    test "respects requested chunk_size", %{bypass: bypass} do
      Bypass.expect_once(bypass, "HEAD", @path, fn conn ->
        conn
        |> put_resp_header("content-length", "3")
        |> put_resp_header("content-type", "foo/bar")
        |> send_chunked(200)
      end)

      assert {:ok, {3, "foo/bar", stream}} =
               Subject.retrieve(@path, port: bypass.port, chunk_size: 2)

      Bypass.expect(bypass, "GET", @path, fn conn ->
        chunk =
          case hd(get_req_header(conn, "range")) do
            "bytes=0-1" -> "fo"
            "bytes=2-2" -> "o"
          end

        resp(conn, 200, chunk)
      end)

      assert ["fo", "o"] == Enum.to_list(stream)
    end
  end

  describe "store" do
    setup %{bypass: bypass} do
      pid = self()

      Bypass.stub(bypass, "POST", @path, fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)

        case conn.query_params do
          %{"uploads" => _} ->
            send(pid, :started)

            resp(conn, 200, """
            <?xml version="1.0" encoding="UTF-8"?>
            <InitiateMultipartUploadResult>
              <Bucket>test</Bucket>
              <Key>#{@path}</Key>
              <UploadId>1</UploadId>
            </InitiateMultipartUploadResult>
            """)

          %{"uploadId" => "1"} ->
            send(pid, :ended)

            resp(conn, 200, """
            <?xml version="1.0" encoding="UTF-8"?>
            <CompleteMultipartUploadResult>
              <Location>http://localhost#{@path}</Location>
              <Bucket>test</Bucket>
              <Key>#{@path}</Key>
              <ETag>"3858f62230ac3c915f300c664312c11f-9"</ETag>
            </CompleteMultipartUploadResult>
            """)
        end
      end)

      Bypass.stub(bypass, "PUT", @path, fn conn ->
        send(pid, :chunk)

        conn
        |> put_resp_header("etag", "#{System.unique_integer([:monotonic])}")
        |> resp(200, "")
      end)

      :ok
    end

    test "data passed through is unchanged", %{bypass: bypass} do
      data = ["foo", "bar"]
      stream = Subject.store(@path, "foo/bar", data, port: bypass.port)

      assert data == Enum.to_list(stream)
    end

    test "multipart upload starts and ends", %{bypass: bypass} do
      data = ["foo", "bar"]
      Subject.store(@path, "foo/bar", data, port: bypass.port) |> Stream.run()

      assert_received :started
      assert_received :ended
    end

    test "uploads once if chunks are small", %{bypass: bypass} do
      data = ["foo", "bar"]
      Subject.store(@path, "foo/bar", data, port: bypass.port) |> Stream.run()

      assert_received :chunk
      refute_received :chunk
    end

    test "uploads twice if chunks are big", %{bypass: bypass} do
      data = [String.pad_leading("", 5 * 1024 * 1024 + 1, "0"), "bar"]
      Subject.store(@path, "foo/bar", data, port: bypass.port) |> Stream.run()

      assert_received :chunk
      assert_received :chunk
      refute_received :chunk
    end
  end
end
