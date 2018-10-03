ExUnit.configure(
  formatters:
    if System.get_env("CI") do
      [JUnitFormatter, ExUnit.CLIFormatter]
    else
      [ExUnit.CLIFormatter]
    end
)

ExUnit.start()
