defmodule Nindo.Application do
  @moduledoc false

  use Application
  import Nindo.Feeds, only: [cache_user_feeds: 0]

  @opts [
    name: Nindo.Supervisor,
    strategy: :one_for_one,
  ]

  @children [
    Task.child_spec(&cache_user_feeds/0),
    {Cachex, name: :rss},
  ]

  def start(_type, _args) do
    DynamicSupervisor.start_link(@opts)
    Supervisor.start_link(@children, strategy: :one_for_one)
  end

end
