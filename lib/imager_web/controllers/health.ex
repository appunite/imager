defmodule ImagerWeb.Controllers.Health do
  use Phoenix.Controller, namespace: ImagerWeb

  @description Mix.Project.config()[:description]

  def get(conn, _params) do
    json(conn, %{
      status: "pass",
      version: version(),
      description: @description
    })
  end

  defp version, do: Application.spec(:imager, :vsn) |> List.to_string()
end
