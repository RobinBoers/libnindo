defmodule Nindo.FeedAgent do
  @moduledoc """
    Cache and update homepage feeds

    The FeedAgent automatically starts when starting Nindo. It caches the homepage feed for every user in the database.

    It has 2 modes:

    - Cache
    - Lookup

  ### Cache mode

    When starting in cache mode, the agent gets and parses all RSS and user feeds. For every user in the database, a cache mode agent is started. It can then be called to update it's state (get and parse again), or just to retrieve the state.

    To fetch and parse all sources, and construct the feed `Nindo.RSS.fetch_posts/1` is used.

  ### Lookup mode

    FeedAgent is only started once in lookup mode, in `Nindo.Feeds.cache_user_feeds/0`
    In lookup mode it stores the pid for every agent started in cache mode. It can then be called to get the pid for a specific username.

  """

  @me __MODULE__

  alias Nindo.{RSS}

  # General helpers

  def get(pid) do
    Agent.get(pid, fn data -> data end)
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
    Agent.update(pid, &RSS.fetch_posts/1, :infinity)
  end

  # Lookup for user feeds

  def start_link() do
    Agent.start_link(fn -> %{} end, name: @me)
  end

  def get_pid(user) do
    get(@me)[user.username]
  end

  def add_user(username, pid) do
    Agent.update(@me, fn users ->
      Map.put(users, username, pid)
    end, :infinity)
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
