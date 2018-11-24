defmodule Imager.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      exec_app(),
      {DynamicSupervisor, name: Imager.Workers, strategy: :one_for_one},
      ImagerWeb.Endpoint
    ]

    if dsn = Application.get_env(:imager, :sentry_dsn) do
      Application.put_env(:sentry, :dsn, dsn)
      Application.put_env(:sentry, :included_environments, [:prod])
    end

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    _ = Application.ensure_all_started(:sentry)

    prometheus()

    opts = [strategy: :one_for_one, name: Imager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ImagerWeb.Endpoint.config_change(changed, removed)

    :ok
  end

  defp exec_app do
    default = System.get_env("IMAGER_USER")

    opts =
      with nil <- Application.get_env(:imager, :user, default) do
        []
      else
        name -> [user: String.to_charlist(name)]
      end

    %{id: :exec_app, start: {:exec, :start_link, [opts]}}
  end

  defp prometheus do
    :prometheus_registry.register_collector(:prometheus_process_collector)

    Imager.Instrumenter.Cache.setup()
    Imager.Instrumenter.Processing.setup()
    Imager.Instrumenter.Storage.setup()
  end
end
