defmodule Imager.Store.Blackhole do
  @behaviour Imager.Store

  @moduledoc """
  `/dev/null` of the stores. All writes will discard data and all reads
  will automatically fail.
  """

  def retrieve(_path, _ops), do: :error

  def store(_path, _mime, stream, _opts), do: stream
end
