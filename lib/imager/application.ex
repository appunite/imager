defmodule Imager.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      ImagerWeb.Endpoint
    ]

    Application.put_env(
      :sentry,
      :dsn,
      Application.get_env(:imager, :sentry_dsn)
    )

    Imager.Stats.start()
    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    opts = [strategy: :one_for_one, name: Imager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ImagerWeb.Endpoint.config_change(changed, removed)

    :ok
  end
end
