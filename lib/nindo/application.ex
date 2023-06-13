defmodule Nindo.Application do
  @moduledoc false

  use Application
  alias Nindo.Cache

  @opts [
    name: Nindo.Supervisor,
    strategy: :one_for_one
  ]

  @children [
    {Cachex, name: :rss},
    Task.child_spec(&Cache.start/0)
  ]

  def start(_type, _args) do
    DynamicSupervisor.start_link(@opts)
    Supervisor.start_link(@children, strategy: :one_for_one)
  end
end
