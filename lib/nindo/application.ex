defmodule Nindo.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  @children [
    worker(Nindo.Agent, [])
  ]
  @opts [strategy: :one_for_one, name: NinDB.Supervisor]

  @impl true
  def start(_type, _args), do:
    Supervisor.start_link(@children, @opts)
end
