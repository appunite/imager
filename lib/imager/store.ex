defmodule Imager.Store do
  @moduledoc """
  Definition of file storage. It will be used for cache and file storage
  in application.
  """

  alias Imager.Instrumenter

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
  @spec retrieve(store, binary, keyword) ::
          {:ok, {size, mime, stream}} | :error
  def retrieve({store, glob_opts}, path, options) do
    with {:ok, {size, mime, stream}} <-
           store.retrieve(path, Keyword.merge(glob_opts, options)),
         do: {:ok, {size, mime, Instrumenter.Storage.retrieved(stream, store)}}
  end

  @doc """
  Save file in store.
  """
  @spec store(stream, store, mime, binary, keyword) :: stream
  def store(stream, {store, glob_opts}, mime, path, options) do
    path
    |> store.store(mime, stream, Keyword.merge(glob_opts, options))
    |> Instrumenter.Storage.saved(store)
  end
end
