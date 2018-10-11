defmodule ImagerWeb.Plug.PipelineInstrumenter do
  @behaviour Plug

  @labels [:status_class, :method, :host, :scheme]

  def setup do
    :prometheus_counter.declare(
      name: :http_requests_total,
      help: "Total number of HTTP requests made.",
      labels: @labels
    )

    :prometheus_histogram.declare(
      name: :http_request_duration_microseconds,
      help: "The HTTP request latencies in microseconds.",
      labels: @labels,
      buckets: :prometheus_http.microseconds_duration_buckets()
    )
  end

  def init(opts), do: opts

  def call(conn, _opts) do
    start = :erlang.monotonic_time(:microsecond)

    Plug.Conn.register_before_send(conn, fn conn ->
      labels = for label <- @labels, do: value_for(label, conn)

      :prometheus_counter.inc(:http_requests_total, labels)

      stop = :erlang.monotonic_time(:microsecond)
      diff = stop - start

      :prometheus_histogram.observe(
        :http_request_duration_microseconds,
        labels,
        diff
      )

      conn
    end)
  end

  defp value_for(:status_class, conn),
    do: :prometheus_http.status_class(conn.status)

  defp value_for(field, conn), do: Map.fetch!(conn, field)
end
