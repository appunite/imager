defmodule Imager.Tool do
  @moduledoc """
  Describe tool used by the current instance to convert images
  """

  @type command ::
          {:thumbnail, binary()}
          | {:strip, any()}
          | {:gravity, binary()}
          | {:extent, binary()}
          | {:flatten, any()}
          | {:background, any()}
          | {:format, binary()}
  @type commands :: [command]

  require Logger

  defmodule UnknownOption do
    defexception [:option, :value, plug_status: 422]

    def exception({option, value}),
      do: %__MODULE__{option: option, value: value}

    def message(%__MODULE__{option: option, value: value}) do
      "Unknown command #{option} with value #{value}"
    end
  end

  defp format(commands), do: Keyword.pop(commands, :format, "png")

  def result(filename, commands) do
    extname = Path.extname(filename)
    dirname = Path.dirname(filename)
    basename = Path.basename(filename, extname)
    {result_ext, commands} = format(commands)

    mime = MIME.type(result_ext)

    {mime, Path.join(dirname, build_path(basename, result_ext, commands))}
  end

  defp build_path(basename, ext, commands) do
    query = Enum.map_join(commands, "_", &path/1)

    basename <> "_" <> query <> "." <> ext
  end

  defp path({:background, color}), do: "background-" <> color
  defp path({:extent, size}), do: "extent-" <> size
  defp path({:flatten, _}), do: "flatten"
  defp path({:gravity, orientation}), do: "gravity-" <> orientation
  defp path({:strip, _}), do: "strip"
  defp path({:thumbnail, size}), do: "thumbnail-" <> size

  def build_command(commands) do
    {format, commands} = format(commands)
    cmds = Enum.flat_map(commands, &command/1)

    ["-[0]"] ++ cmds ++ ["-quality", "40"] ++ [format <> ":-"]
  end

  defp command({:background, color}), do: ["-background", color]
  defp command({:extent, size}), do: ["-extent", size]
  defp command({:flatten, _}), do: ["-flatten"]
  defp command({:gravity, orientation}), do: ["-gravity", orientation]
  defp command({:strip, _}), do: ["-strip"]
  defp command({:thumbnail, size}), do: ["-thumbnail", size]

  def from_query(query), do: query |> Enum.map(&string/1)

  defp string({"background", color}), do: {:background, color}
  defp string({"extent", size}), do: {:extent, size}
  defp string({"flatten", _}), do: {:flatten, true}
  defp string({"gravity", orientation}), do: {:gravity, orientation}
  defp string({"strip", _}), do: {:strip, true}
  defp string({"thumbnail", size}), do: {:thumbnail, size}
  defp string({"format", format}), do: {:format, format}
  defp string(option), do: raise(UnknownOption, option)
end
