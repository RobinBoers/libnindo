defmodule Nindo.MixProject do
  use Mix.Project

  def project, do: [
    app: :nindo,
    version: "0.1.0",
    elixir: "~> 1.12",
    start_permanent: Mix.env() == :prod,
    deps: deps(),
    name: "Nindo",
    source_url: "https://github.com/RobinBoers/nindo-elixir",
    docs: [
      main: "readme",
      logo: "logo.png",
      api_reference: false,
      extras: ["README.md"],
      source_ref: "master"
    ],
  ]

  def application, do: [
    mod: {Nindo.Application, []},
    extra_applications: [:logger],
  ]

  defp deps, do: [
    {:bcrypt_elixir, "~> 2.3.0"},
    {:nindb, github: "RobinBoers/nindo-nindb"},
    {:fast_rss, github: "RobinBoers/fast_rss"},
    {:html_sanitize_ex, github: "RobinBoers/html-sanitize-ex"},
    {:rss, "~> 0.2.1", github: "BennyHallett/elixir-rss"},
    {:httpoison, "~> 1.8"},
    {:calendar, "~> 1.0.0"},
    {:jason, "~> 1.2"},
    {:cachex, "~> 3.4"},
    {:ex_doc, "~> 0.24", only: :dev, runtime: false},
    {:earmark, "~> 1.4"},
  ]
end
