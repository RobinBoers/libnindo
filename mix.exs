defmodule Nindo.MixProject do
  use Mix.Project

  def project, do: [
    app: :nindo,
    version: "0.1.0",
    elixir: "~> 1.12",
    start_permanent: Mix.env() == :prod,
    deps: deps(),
  ]

  def application, do: [
    extra_applications: [:logger],
  ]

  defp deps, do: [
    {:bcrypt_elixir, "~> 2.3.0"},
    {:nin_db, path: "../nindb"},
    {:fast_rss, path: "../fast_rss"},
    {:html_sanitize_ex, "~> 1.4"},
    {:rss, "~> 0.2.1"},
    {:httpoison, "~> 1.8"},
    {:calendar, "~> 1.0.0"},
  ]
end
