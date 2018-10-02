use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :imager, ImagerWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :imager, :port, 4000

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :imager, :stores, %{
  "local" => %{
    store: {Imager.Store.Local, dir: "test/fixtures/"},
    cache: {Imager.Store.Local, dir: "tmp/cache/"}
  }
}

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
