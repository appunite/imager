defmodule Imager.Instrumenter do
  def setup do
    :prometheus_registry.register_collector(:prometheus_process_collector)

    Imager.Instrumenter.Cache.setup()
    Imager.Instrumenter.Processing.setup()
    Imager.Instrumenter.Storage.setup()
  end
end
