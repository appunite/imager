defmodule Imager.Instrumenter.Storage do
  def setup do
    :prometheus_counter.declare(
      name: :store_retrieved_total,
      help: "Count of retrieves from the given store",
      labels: [:store]
    )

    :prometheus_counter.declare(
      name: :store_saved_total,
      help: "Count of saves into the given store",
      labels: [:store]
    )

    :prometheus_summary.declare(
      name: :store_retrieved_bytes,
      help: "Bytes retrieved from the store",
      labels: [:store]
    )

    :prometheus_summary.declare(
      name: :store_saved_bytes,
      help: "Saved bytes to given store",
      labels: [:store]
    )
  end

  def retrieved(stream, store) do
    :prometheus_counter.inc(:store_retrieved_total, [store])

    Stream.each(
      stream,
      &:prometheus_summary.observe(
        :store_retrieved_bytes,
        [store],
        byte_size(&1)
      )
    )
  end

  def saved(stream, store) do
    :prometheus_counter.inc(:store_saved_total, [store])

    Stream.each(
      stream,
      &:prometheus_summary.observe(:store_saved_bytes, [store], byte_size(&1))
    )
  end
end
