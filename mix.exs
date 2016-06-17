defmodule Authsense.Mixfile do
  use Mix.Project

  @version "0.0.1"
  @description """
  Sensible helpers for authentication for Phoenix/Ecto.
  """

  def project do
    [app: :authsense,
     version: @version,
     description: @description,
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/rstacruz/authsense",
     homepage_url: "https://github.com/rstacruz/authsense",
     docs: docs,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, ">= 1.0.0"},
      {:plug, ">= 1.0.0"},
      {:comeonin, ">= 2.4.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:postgrex, "~> 0.11.2", only: :test}
    ]
  end

  def package do
    [
      maintainers: ["Rico Sta. Cruz"],
      licenses: ["MIT"],
      files: ["lib", "mix.exs", "README.md"],
      links: %{github: "https://github.com/rstacruz/expug"}
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "Authsense",
      extras: [
        Path.wildcard("*.md") |
        Path.wildcard("docs/**/*.md")
      ]
    ]
  end
end
