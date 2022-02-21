defmodule FishingSpot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fishing_spot,
      version: "0.0.1",
      elixir: "~> 1.12",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Docs
      name: "Fishing Spot",
      source_url: "https://github.com/KaseyCantu/fishing_spot",
      homepage_url: "http://YOUR_PROJECT_HOMEPAGE.com",
      docs: [
        # The main page in the docs
        main: "Fishing Spot",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {FishingSpot, []},
      extra_applications: [:logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:ecto, "~> 3.7"},
      {:ecto_sql, "~> 3.7"},
      {:ex_doc, "~> 0.28.0", only: :dev, runtime: false},
      {:postgrex, "~> 0.16.1"}
    ]
  end

  defp aliases do
    ["ecto.rebuild": ["ecto.drop", "ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"]]
  end
end
