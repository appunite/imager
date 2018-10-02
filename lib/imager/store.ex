defmodule Imager.Store do
  @moduledoc """
  Definition of file storage. It will be used for cache and file storage
  in application.
  """

  alias Imager.Stats

  @type size :: non_neg_integer()
  @type stream :: Enumerable.t()
  @type mime :: binary()

  @type t :: %{
    store: store(),
    cache: store()
  }
  @type store :: {module(), keyword()}

  @callback retrieve(path :: binary(), opts :: keyword()) ::
              {:ok, {size, stream}} | :error
  @callback store(
              path :: binary(),
              mime :: binary(),
              stream,
              opts :: keyword()
            ) :: stream

  @doc """
  Retreive file from store.
  """
  @spec retrieve(store, binary, keyword) :: {:ok, {size, mime, stream}}  | :error
  def retrieve({store, glob_opts}, path, options) do
    Stats.increment("imager.store.retrieve", 1, Stats.tags(~w(module:#{store})))
    store.retrieve(path, Keyword.merge(glob_opts, options))
  end

  @doc """
  Save file in store.
  """
  @spec store(stream, store, mime, binary, keyword) :: stream
  def store(stream, {store, glob_opts}, mime, path, options) do
    Stats.increment("imager.store.store", 1, Stats.tags(~w(module:#{store})))
    store.store(path, mime, stream, Keyword.merge(glob_opts, options))
  end
end
