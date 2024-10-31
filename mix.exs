defmodule Lynx.MixProject do
  use Mix.Project

  @version "0.1.3"

  def project do
    [
      app: :lynx,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:floki, ">= 0.30.0"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.2"},
      {:phoenix, "~> 1.7", runtime: false},
      {:phoenix_html_helpers, "~> 1.0"}
    ]
  end

  defp description() do
    "Rich application linking features"
  end

  defp package() do
    [
      name: :lynx,
      licenses: ["Apache-2.0"],
      links: %{}
    ]
  end

  def elixirc_paths(:test), do: ["test/helpers" | elixirc_paths(:prod)]
  def elixirc_paths(_), do: ["lib"]
end
