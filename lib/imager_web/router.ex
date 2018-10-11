defmodule ImagerWeb.Router do
  use Phoenix.Router
  use Plug.ErrorHandler
  use Sentry.Plug

  import Phoenix.Controller

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ImagerWeb.Controllers do
    pipe_through(:api)

    get("/__health", Health, :get)

    get("/:store/*path", Image, :get)
  end
end
