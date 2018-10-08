defmodule Imager.Mixfile do
  use Mix.Project

  @description """
  Image transformation proxy service.

  For details check out: <https://github.com/appunite/imager>
  """

  def project do
    [
      app: :imager,
      version: version(),
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:vmstats]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.circle": :test,
        "coveralls.html": :test
      ],
      description: @description
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Imager.Application, []},
      extra_applications: [:logger, :inets, :runtime_tools],
      included_applications: [:vmstats, :erlexec]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      {:distillery, "~> 2.0"},
      {:statix, ">= 0.0.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:jason, ">= 0.0.0"},
      {:vmstats, "~> 2.2", runtime: false},
      {:sentry, "~> 7.0"},
      {:porcelain, "~> 2.0.3"},
      {:erlexec, "~> 1.9", runtime: false},
      {:jose, "~> 1.8"},
      {:toml, "~> 0.3"},
      {:mockery, "~> 2.2.0"},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:junit_formatter, "~> 2.2", only: [:test]},
      {:excoveralls, "~> 0.10", only: [:test]},
      {:stream_data, "~> 0.1", only: [:test]},
      {:temp, "~> 0.4", only: [:test]},
      {:bypass, "~> 0.9", only: [:test]}
    ]
  end

  defp version do
    case System.cmd("git", ~w(describe)) do
      {vers, 0} -> String.trim(vers)
      _ -> "0.0.0"
    end
  end
end
