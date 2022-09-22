defmodule Lynx.MixProject do
  use Mix.Project

  def project do
    [
      app: :lynx,
      version: "0.2.0",
      elixir: "~> 1.11",
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
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:phoenix, "~> 1.6", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 1.8"},
      {:floki, "~> 0.33"},
      {:jason, "~> 1.4"},
      {:phoenix_html, "~> 3.2"}
    ]
  end

  defp description() do
    "Rich application linking features"
  end

  defp package() do
    [
      name: :lynx,
      organization: :equip,
      licenses: ["Apache-2.0"],
      links: %{}
    ]
  end

  def elixirc_paths(:test), do: ["test/helpers" | elixirc_paths(:prod)]
  def elixirc_paths(_), do: ["lib"]
end
