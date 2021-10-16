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
    mod: {Nindo.Application, []},
    extra_applications: [:logger],
  ]

  defp deps, do: [
    {:bcrypt_elixir, "~> 2.3.0"},
    {:nin_db, path: "../nindb"},
  ]
end
