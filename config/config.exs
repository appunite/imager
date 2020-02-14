# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :json_library, Jason

# Configures the endpoint
config :imager, ImagerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ImagerWeb.Views.Error, accepts: ~w(json)],
  instrumenters: [Prometheus.PhoenixInstrumenter]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: :all

config :phoenix, :format_encoders, json: Jason

config :ex_aws,
  access_key_id: "${AWS_ACCESS_KEY_ID}",
  secret_access_key: "${AWS_SECRET_ACCESS_KEY}",
  json_codec: Jason

config :sentry,
  included_environments: [],
  release: Mix.Project.config()[:version],
  environment_name: Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
