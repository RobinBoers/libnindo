defmodule Nindo.Cache do
  @moduledoc false

  alias Nindo.{Accounts, FeedAgent}

  def start() do
    start_lookup()

    Accounts.list()
    |> Enum.map(&Task.async(put(&1)))
    |> Task.await_many(:infinity)
  end

  def put(user) do
    if user.sources and user.following do
      pid = start_user(user)

      FeedAgent.add_user(user.username, pid)
      FeedAgent.update(pid)
    end
  end

  def get(user) do
    user
    |> FeedAgent.get_pid()
    |> FeedAgent.get()
  end

  def refresh(user) do
    user
    |> FeedAgent.get_pid()
    |> FeedAgent.update()
  end

  defp start_lookup() do
    DynamicSupervisor.start_child(Nindo.Supervisor, FeedAgent.child_spec())
  end

  defp start_user(user) do
    {:ok, pid} =
      DynamicSupervisor.start_child(Nindo.Supervisor, FeedAgent.child_spec(user.username))

    pid
  end
end
