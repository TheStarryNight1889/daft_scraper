defmodule DaftScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :daft_scraper,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DaftScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.36.0"},
      {:req, "~> 0.5.0"},
      {:poison, "~> 6.0"}
    ]
  end
end
