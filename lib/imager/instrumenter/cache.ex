defmodule Imager.Instrumenter.Cache do
  def setup do
    :prometheus_counter.declare(
      name: :cache_hits_total,
      help: "Count of cached images hits",
      labels: [:type, :store]
    )
  end

  def passthrough({store, _}),
    do: :prometheus_counter.inc(:cache_hits_total, [:passthrough, store])

  def cache_hit({store, _}),
    do: :prometheus_counter.inc(:cache_hits_total, [:cache, store])
end
