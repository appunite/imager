defmodule Imager.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      exec_app(),
      {DynamicSupervisor, name: Imager.Workers, strategy: :one_for_one},
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

  defp exec_app do
    opts =
      with {:ok, name} when not is_nil(name) <-
             Application.fetch_env(:imager, :user) do
        [user: String.to_charlist(name)]
      else
        _ -> []
      end

    %{id: :exec_app, start: {:exec, :start_link, [opts]}}
  end
end
