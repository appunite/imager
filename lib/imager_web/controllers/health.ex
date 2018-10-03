defmodule ImagerWeb.Controllers.Health do
  use Phoenix.Controller, namespace: ImagerWeb

  @description Mix.Project.config()[:description]

  def get(conn, _params) do
    json(conn, %{
      status: "pass",
      version: Imager.Stats.version(),
      description: @description
    })
  end
end
