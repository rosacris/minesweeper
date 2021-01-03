defmodule Minesweeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :minesweeper,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:memento, :poison],
      extra_applications: [:logger, :plug_cowboy],
      mod: {Minesweeper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:memento, "~> 0.3.1"},
      {:plug_cowboy, "~> 2.4"},
      {:poison, "~> 4.0"}
    ]
  end
end
