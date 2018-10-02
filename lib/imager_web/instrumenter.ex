defmodule ImagerWeb.Instrumenter do
  @moduledoc """
  Instrument application.

  This module gathers statistics about running application and sends them to StatsD compatible server.
  """

  def phoenix_controller_call(:start, _, %{conn: conn}) do
    Imager.Stats.tags(~w[
      host:#{conn.host}
      method:#{conn.method}
      scheme:#{conn.scheme}
      controller:#{module_name(conn.private[:phoenix_controller])}
      action:#{conn.private[:phoenix_action]}
      format:#{conn.private[:phoenix_format] || "unknown"}
    ])
  end

  def phoenix_controller_call(:stop, time, tags) do
    Imager.Stats.histogram("phoenix.request.duration", time, tags: tags)
  end

  defp module_name(nil), do: nil
  defp module_name("Elixir." <> name), do: name
  defp module_name(name) when is_bitstring(name), do: name

  defp module_name(name) when is_atom(name), do: module_name(Atom.to_string(name))
end

