defmodule ImagerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :imager
  use Sentry.Phoenix.Endpoint

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.Head)

  plug(ImagerWeb.Router)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    port =
      Application.get_env(:imager, :port) || System.get_env("PORT") ||
        raise "expected the PORT environment variable to be set"

    {:ok, Keyword.put(config, :http, [:inet6, port: port])}
  end
end
