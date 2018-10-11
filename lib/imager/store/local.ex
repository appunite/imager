defmodule Imager.Store.Local do
  @behaviour Imager.Store

  @moduledoc """
  Store that uses local directory as a source of the images
  """

  require Logger

  def retrieve(path, opts) do
    dir = Keyword.get(opts, :dir, ".")
    full_path = Path.join(dir, path)

    extname =
      case Path.extname(path) do
        "." <> extname -> extname
        extname -> extname
      end

    mime = MIME.type(extname)

    with {:ok, %File.Stat{size: size}} <- File.stat(full_path) do
      {:ok, {size, mime, File.stream!(full_path, [], 2 * 1024)}}
    else
      _ -> :error
    end
  end

  def store(path, _mime, stream, opts) do
    dir = Keyword.get(opts, :dir, ".")
    full_path = Path.join(dir, path)

    :ok = File.mkdir_p!(dir)

    {:ok, file} = :file.open(full_path, [:write, :raw])

    stream
    |> Stream.each(fn chunk ->
      :file.write(file, chunk)
    end)
  end
end
