defmodule Imager.Config.StoreTransform do
  @behaviour Toml.Transform

  @moduledoc """
  Transform store definitions to expected internal format
  """

  require Logger

  @reserved ~w[health]
  @types ~w[S3 Local Blackhole]

  def transform(:stores, entries) do
    Map.new(entries, fn {path, values} ->
      with {:ok, store} <- get_store(values),
           {:ok, cache} <- get_cache(values) do
        path = to_string(path)

        if path in @reserved, do: raise("'#{path}' is reserved name")

        if String.contains?(path, "/"),
          do: raise("'#{path}' cannot contain '/'")

        {path,
         %{
           store: store,
           cache: cache
         }}
      else
        _ ->
          raise """
                Invalid store `#{path}` definition, store needs to be defined in form

                  [stores.path]
                  type = {#{list()}

                or

                  [stores.path.store]
                  type = {#{list()}
                  [stores.path.cache]
                  type = {#{list()}}

                Got #{inspect entries}
                """
      end
    end)
  end

  def transform(_k, value), do: value

  defp get_store(%{store: values}), do: parse(values)
  defp get_store(values), do: parse(values)

  defp get_cache(%{cache: values}), do: parse(values)
  defp get_cache(values), do: parse(values)

  defp parse(%{type: type} = values) when type in @types do
    module = Module.safe_concat(Imager.Store, type)
    opts = Keyword.new(Map.get(values, :options, []))

    {:ok, {module, opts}}
  end

  defp parse(values), do: {:error, values}

  defp list do
    [last | rest] = @types

    Enum.join(rest, ", ") <> " or " <> last
  end
end
