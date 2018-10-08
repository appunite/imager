defmodule Imager.Store.S3 do
  @behaviour Imager.Store

  alias ExAws.S3

  @moduledoc """
  S3 compatible storage. It will try to stream files as much as possible
  in both ways.
  """

  require Logger

  def retrieve(path, opts) do
    {bucket, config} = Keyword.pop(opts, :bucket)
    {chunk_size, config} = Keyword.pop(config, :chunk_size, 2 * 1024)

    with {:ok, size, mime} <- get_file_size(bucket, path, config) do
      stream =
        size
        |> stream(chunk_size)
        |> Stream.map(&get_chunk(bucket, path, &1, opts))

      {:ok, {size, mime, stream}}
    end
  end

  def store(path, mime, stream, opts) do
    {bucket, config} = Keyword.pop(opts, :bucket)

    stream
    |> Stream.transform(
      fn ->
        %{body: body} =
          bucket
          |> S3.initiate_multipart_upload(path, content_type: mime)
          |> ExAws.request!(config)

        {body.upload_id, 1, [], <<>>}
      end,
      fn data, {id, idx, etags, chunk} ->
        chunk = chunk <> data

        # This magic is needed due to fact that S3 disallows to have multiple
        # chunks that are smaller than 5 MiB, only last one can be smaller. So
        # there we group the chunks to be at least 5 MiB
        if byte_size(chunk) > 5 * 1024 * 1024 do
          %{headers: headers} =
            bucket
            |> S3.upload_part(path, id, idx, chunk)
            |> ExAws.request!(config)

          etag = header_find(headers, "Etag")

          {[data], {id, idx + 1, [{idx, etag} | etags], <<>>}}
        else
          {[data], {id, idx, etags, chunk}}
        end
      end,
      fn {id, idx, etags, data} ->
        # We can have some leftovers in data if the file size wasn't multiply of
        # 5Mi, so now we upload last chunk
        %{headers: headers} =
          bucket
          |> S3.upload_part(path, id, idx, data)
          |> ExAws.request!(config)

        etag = header_find(headers, "Etag")
        etags = [{idx, etag} | etags]

        bucket
        |> ExAws.S3.complete_multipart_upload(path, id, Enum.reverse(etags))
        |> ExAws.request!(config)
      end
    )
  end

  defp stream(size, chunk_size) do
    Stream.unfold(0, fn
      counter when counter * chunk_size < size ->
        start_byte = counter * chunk_size
        end_byte = (counter + 1) * chunk_size

        {{start_byte, min(end_byte, size) - 1}, counter + 1}

      _ ->
        nil
    end)
  end

  defp get_chunk(bucket, path, {start_byte, end_byte}, config) do
    %{body: body} =
      bucket
      |> S3.get_object(path, range: "bytes=#{start_byte}-#{end_byte}")
      |> ExAws.request!(config)

    body
  end

  defp get_file_size(bucket, path, config) do
    with {:ok, %{headers: headers}} <-
           bucket
           |> S3.head_object(path)
           |> ExAws.request(config),
         value when not is_nil(value) <-
           header_find(headers, "Content-Length"),
         {length, ""} <- Integer.parse(value),
         mime =
           header_find(headers, "Content-Type") || "application/octet-stream" do
      {:ok, length, mime}
    else
      _ -> :error
    end
  end

  defp header_find(headers, name) do
    name = String.downcase(name)

    Enum.find_value(headers, fn {key, value} ->
      if String.downcase(key) == name, do: value
    end)
  end
end
