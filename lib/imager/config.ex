defmodule Imager.Config do
  @moduledoc """
  Configuration transformer
  """

  @transforms [
    Imager.Config.EnvTransform,
    Imager.Config.PortNormalization,
    Imager.Config.StoreTransform
  ]

  def init(opts) do
    path = Keyword.fetch!(opts, :path)

    opts =
      opts
      |> Keyword.put(:keys, :atoms)
      |> Keyword.put(:transforms, @transforms)

    with {:ok, expanded} <- Toml.Provider.expand_path(path),
         {:ok, map} <- Toml.decode_file(expanded, opts) do
      persist(map)
    else
      {:error, {:invalid_toml, _}} = error -> raise Toml.Error, error
      _ -> :ok
    end
  end

  defp persist(map) when is_map(map) do
    for {key, values} <- map do
      values = deep_merge(Application.get_env(:imager, key), values)

      Application.put_env(:imager, key, values, persistent: true)
    end

    :ok
  end

  defp deep_merge(nil, b), do: b
  defp deep_merge(a, b), do: deep_merge(nil, a, b)

  defp deep_merge(_k, a, b) when is_list(a) and is_list(b) do
    if Keyword.keyword?(a) and Keyword.keyword?(b) do
      Keyword.merge(a, b, &deep_merge/3)
    else
      b
    end
  end

  defp deep_merge(_k, a, b) when is_map(a) and is_map(b) do
    Map.merge(a, b, &deep_merge/3)
  end

  defp deep_merge(_k, _a, b), do: b
end
