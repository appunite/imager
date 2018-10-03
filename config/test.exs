use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :imager, ImagerWeb.Endpoint,
  server: false,
  instrumenters: []

config :imager, :port, 4001

config :logger, :console, format: "[$level] $message\n"

# Print only warnings and errors during test
config :logger, level: :warn
