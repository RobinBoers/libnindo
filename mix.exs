defmodule Nindo.MixProject do
  use Mix.Project

  def project, do: [
    app: :nindo,
    version: "0.1.0",
    elixir: "~> 1.12",
    start_permanent: Mix.env() == :prod,
    deps: deps(),
    name: "Nindo",
    source_url: "https://github.com/RobinBoers/Nindo2",
    docs: [
      main: "readme",
      extras: ["README.md", "ABOUT.md", "CLIENTS.md"]
    ],
  ]

  def application, do: [
    mod: {Nindo.Application, []},
    extra_applications: [:logger],
  ]

  defp deps, do: [
    {:bcrypt_elixir, "~> 2.3.0"},
    {:nin_db, path: "../nindb"},
    {:fast_rss, path: "../fast_rss"},
    {:html_sanitize_ex, path: "../html_sanitize_ex"},
    {:rss, "~> 0.2.1"},
    {:httpoison, "~> 1.8"},
    {:calendar, "~> 1.0.0"},
    {:jason, "~> 1.2"},
    {:cachex, "~> 3.4"},
    {:ex_doc, "~> 0.24", only: :dev, runtime: false},
  ]
end
