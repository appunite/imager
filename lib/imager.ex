defmodule Imager do
  @moduledoc """
  Imager keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Mockery.Macro

  require Logger

  alias Imager.Stats
  alias Imager.Store
  alias Imager.Tool

  @type size :: non_neg_integer() | :unknown
  @type mime :: binary()
  @type stream :: Enumerable.t()

  @spec process(Store.t(), binary(), Tool.commands()) ::
          {:ok, {size, mime, stream}}
  @spec process(Store.t(), binary(), Tool.commands(), keyword()) ::
          {:ok, {size, mime, stream}}
  def process(store, file_name, commands, opts \\ [])

  def process(%{store: store}, file_name, [], opts) do
    Stats.increment("imager.passthrough", 1, tags: Stats.tags())

    Store.retrieve(store, file_name, opts)
  end

  def process(%{store: store, cache: cache}, file_name, commands, opts) do
    {mime, result_name} = Tool.result(file_name, commands)
    args = Tool.build_command(commands)
    tags = Stats.tags(~w(
      store:#{elem(store, 0)}
      cache:#{elem(cache, 0)}
    ))

    Logger.metadata(input: file_name, commands: inspect(commands))
    Logger.debug(inspect(args))

    with :error <- Store.retrieve(cache, result_name, opts),
         {:ok, {_, _, in_stream}} <- Store.retrieve(store, file_name, opts) do
      Logger.debug("Start processing")
      Stats.increment("imager.process.started", 1, tags: tags)

      {pid, out_stream} = runner().stream(executable(), args)

      runner().feed_stream(pid, in_stream)

      case runner().wait(pid) do
        :ok ->
          Stats.increment("imager.process.succeeded", 1, tags: tags)

          stream =
            out_stream
            |> Store.store(cache, mime, result_name, opts)

          {:ok, {:unknown, mime, stream}}

        _ ->
          Stats.increment("imager.process.failed", 1, tags: tags)

          :failed
      end
    else
      {:ok, {_, _, _}} = result ->
        Logger.debug("Cache hit")
        Stats.increment("imager.process.cache_hit", 1, tags: tags)

        result

      _ ->
        :error
    end
  end

  @spec store(name :: binary()) :: {:ok, Store.t()} | :error
  def store(name) do
    with {:ok, stores} <- Application.fetch_env(:imager, :stores),
         {:ok, store} = result <- Map.fetch(stores, name) do
      %{store: {store_mod, _}, cache: {cache_mod, _}} = store

      Logger.metadata(store: store_mod, cache: cache_mod)

      result
    end
  end

  defp runner, do: mockable(Imager.Runner)

  defp executable, do: Application.get_env(:imager, :executable, "convert")
end
