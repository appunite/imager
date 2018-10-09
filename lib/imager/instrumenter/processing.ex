defmodule Imager.Instrumenter.Processing do
  def setup do
    :prometheus_counter.declare(
      name: :processed_total,
      help: "Count of processed images",
      labels: [:status, :store]
    )

    :prometheus_counter.declare(
      name: :process_commands_total,
      help: "Processing commands defined",
      labels: [:command, :argument]
    )
  end

  def succeeded({store, _}),
    do: :prometheus_counter.inc(:processed_total, ["ok", store])

  def failed({store, _}),
    do: :prometheus_counter.inc(:processed_total, ["failed", store])

  def command({command, argument}),
    do: :prometheus_counter.inc(:process_commands_total, [command, argument])

  def command(list) when is_list(list), do: Enum.each(list, &command/1)
end
