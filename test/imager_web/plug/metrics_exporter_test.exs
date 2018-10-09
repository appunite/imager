defmodule ImagerWeb.Plug.MetricsExporterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties

  alias ImagerWeb.Plug.MetricsExporter, as: Subject

  defp path do
    gen all segments <-
              list_of(string(:alphanumeric, min_length: 1), min_length: 1) do
      "/" <> Path.join(segments)
    end
  end

  defp http_method do
    ~w(get post delete patch put head)
    |> Enum.map(&constant/1)
    |> one_of()
  end

  property "non-metric endpoints are passed through" do
    opts = Subject.init(endpoint: "/metric")

    check all path <- path(),
              method <- http_method(),
              path != "/metric" do
      conn = conn(method, path)

      assert conn == Subject.call(conn, opts)
    end
  end

  test "metric endpoint return 200" do
    opts = Subject.init(endpoint: "/metric")
    conn = conn(:get, "/metric")

    assert {200, _, _} = sent_resp(Subject.call(conn, opts))
  end
end
