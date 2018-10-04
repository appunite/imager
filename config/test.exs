use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :imager, ImagerWeb.Endpoint,
  server: false,
  instrumenters: []

config :imager, :port, 4001

config :logger, :console, format: "[$level] $message\n"

config :junit_formatter,
  report_file: "report.xml",
  report_dir: "reports/exunit"

config :ex_aws,
  access_key_id: "SampleKeyId",
  secret_access_key: "SampleSecretKeyId",
  s3: [
    host: "localhost",
    scheme: "http://",
    bucket: "test"
  ],
  retries: [max_attempts: 1]

# Print only warnings and errors during test
config :logger, level: :warn
