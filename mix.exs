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
      included_applications: [:vmstats]
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
      {:jose, "~> 1.8"},
      {:toml, "~> 0.3"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp version do
    case System.cmd("git", ~w(describe)) do
      {vers, 0} -> String.trim(vers)
      _ -> "0.0.0"
    end
  end
end
