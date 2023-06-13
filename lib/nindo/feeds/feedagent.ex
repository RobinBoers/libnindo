defmodule Nindo.FeedAgent do
  @moduledoc false

  @me __MODULE__

  alias Nindo.{Feeds}

  # General helpers

  def get(pid) do
    Agent.get(pid, fn data -> data end, :infinity)
  end

  # Feed managment

  def start_link(username) do
    Agent.start_link(fn -> {username, nil} end)
  end

  def get_posts(pid) do
    {_username, posts} = get(pid)
    posts
  end

  def update(pid) do
    Task.async(fn ->
      Agent.update(pid, &Feeds.fetch/1, :infinity)
    end)
  end

  # Lookup for user feeds

  def start_link() do
    Agent.start_link(fn -> %{} end, name: @me)
  end

  def get_pid(user) do
    get(@me)[user.username]
  end

  def add_user(username, pid) do
    Agent.update(
      @me,
      fn users ->
        Map.put(users, username, pid)
      end,
      :infinity
    )
  end

  # Child spec

  def child_spec(args) do
    %{
      id: @me,
      start: {@me, :start_link, [args]}
    }
  end

  def child_spec() do
    %{
      id: @me,
      start: {@me, :start_link, []}
    }
  end
end
