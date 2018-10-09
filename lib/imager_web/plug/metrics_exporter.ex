defmodule ImagerWeb.Plug.MetricsExporter do
  @behaviour Plug

  import Plug.Conn

  require Logger

  def setup do
    :prometheus_summary.declare(
      name: :telemetry_scrape_duration_ms,
      help: "Scrape duration",
      labels: [:content_type]
    )

    :prometheus_summary.declare(
      name: :telemetry_scrape_size_bytes,
      help: "Scrape size, uncompressed",
      labels: [:content_type]
    )
  end

  def init(opts), do: opts

  def call(conn, opts) do
    opts =
      opts
      |> Keyword.merge(Application.get_env(:imager, :prometheus, []))
      |> Keyword.put_new(:endpoint, "/metrics")
      |> Keyword.update(:format, :prometheus_text_format, &parse_format/1)

    endpoint = Keyword.fetch!(opts, :endpoint)

    case conn.request_path do
      ^endpoint -> send_stats(conn, opts)
      _ -> conn
    end
  end

  defp send_stats(conn, opts) do
    format = Keyword.fetch!(opts, :format)

    {type, data} = scrape_data(format)

    conn
    |> put_resp_content_type(type)
    |> send_resp(200, data)
    |> halt()
  end

  defp scrape_data(format) do
    start = :erlang.monotonic_time(:millisecond)

    try do
      format.format(:default)
    else
      value ->
        stop = :erlang.monotonic_time(:millisecond)
        type = format.content_type()

        :prometheus_summary.observe(
          :telemetry_scrape_duration_ms,
          [type],
          stop - start
        )

        :prometheus_summary.observe(
          :telemetry_scrape_size_bytes,
          [type],
          :erlang.iolist_size(value)
        )

        {type, value}
    end
  end

  defp parse_format(nil), do: :prometheus_text_format
  defp parse_format("text"), do: :prometheus_text_format
  defp parse_format("protobuf"), do: :prometheus_protobuf_format

  defp parse_format(format) do
    Logger.warn("Unknown format #{inspect(format)}, falling back to \"text\"")

    :prometheus_text_format
  end
end
