defmodule KinoPhoenixLiveView.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_phoenix_live_view,
      version: "0.1.0",
      elixir: "~> 1.18",
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
      {:kino, "~> 0.14.2"},
      {:jason, "~> 1.4"},
      {:phoenix_live_view, "~> 1.0"}
    ]
  end
end
