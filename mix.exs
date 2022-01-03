defmodule Esolix.MixProject do
  use Mix.Project

  def project do
    [
      app: :esolix,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.26", only: :dev, runtime: false},
      {:imagineer, git: "https://github.com/tyre/imagineer", ref: "a6872296756cde19f8f575a7d1854d0fe7cbcb02"},

    ]
  end
end
