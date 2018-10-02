defmodule Imager.Store.Dummy do
  @moduledoc false

  def retrieve(path, opts) do
    case Imager.Store.Local.retrieve(path, opts) do
      {:ok, _} = result ->
        if ref = Keyword.get(opts, :ref) do
          send(self(), {:retrieved, ref, path})
        end

        result
      :error ->
        if ref = Keyword.get(opts, :ref) do
          send(self(), {:missed, ref, path})
        end

        :error
    end
  end

  def store(path, mime, stream, opts) do
    if ref = Keyword.get(opts, :ref) do
      send(self(), {:store, ref, path, mime})
    end

    stream
  end
end
