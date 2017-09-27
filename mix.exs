defmodule Authsense.Mixfile do
  use Mix.Project

  @version "0.4.0"
  @description """
  Sensible helpers for authentication for Phoenix/Ecto.
  """

  def project do
    [app: :authsense,
     version: @version,
     description: @description,
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/rstacruz/authsense",
     homepage_url: "https://github.com/rstacruz/authsense",
     docs: docs(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ecto]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:plug, "~> 1.4"},
      {:comeonin, "~> 4.0"},
      {:pbkdf2_elixir, "~> 0.12", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  def package do
    [
      maintainers: ["Rico Sta. Cruz"],
      licenses: ["MIT"],
      files: ["lib", "mix.exs", "README.md"],
      links: %{github: "https://github.com/rstacruz/authsense"}
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "Authsense",
      extras:
        Path.wildcard("*.md") ++
        Path.wildcard("docs/**/*.md")
    ]
  end
end
