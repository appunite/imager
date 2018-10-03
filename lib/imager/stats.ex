defmodule Imager.Stats do
  @moduledoc """
  StatsD statistics gatherer.
  """

  @behaviour :vmstats_sink

  use Statix, runtime_config: true

  def start do
    if config = Application.get_env(:imager, :stats) do
      Application.put_env(:statix, __MODULE__,
        host: Map.fetch!(config, :host),
        port: Map.fetch!(config, :port)
      )
    end

    connect()
    {:ok, _} = Application.ensure_all_started(:vmstats, :permanent)

    :ok
  end

  def collect(type, key, value) do
    do_collect(
      type,
      List.to_string(key),
      value,
      tags()
    )
  end

  def tags(tags \\ []) when is_list(tags) do
    ["app:imager", "version:#{version()}" | tags]
  end

  defp do_collect(:counter, key, value, opts), do: increment(key, value, opts)
  defp do_collect(:gauge, key, value, opts), do: gauge(key, value, opts)
  defp do_collect(:timing, key, value, opts), do: histogram(key, value, opts)

  def version, do: :imager |> Application.spec(:vsn) |> List.to_string()
end
