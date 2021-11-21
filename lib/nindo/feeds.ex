defmodule Nindo.Feeds do
  @moduledoc """
    Manage sources and RSS feeds
  """

  alias Nindo.{Accounts, FeedAgent, RSS}
  alias NinDB.{Database, Account}

  def add(feed, user) do
    feeds = user.feeds
    if feed not in feeds do
      Accounts.change(:feeds, [feed | feeds], user)
    end
    update_agent(user)
  end

  def remove(feed, user) do
    feed = empty_to_nil(feed)
    feeds = user.feeds
    if feed in feeds do
      Accounts.change(:feeds, feeds -- [feed], user)
    end
    update_agent(user)
  end

  def follow(person, user) do
    following = user.following
    if person not in following do
      Accounts.change(:following, [person | following], user)
    end
    update_agent(user)
  end

  def unfollow(person, user) do
    following = user.following
    if person in following do
      Accounts.change(:following, following -- [person], user)
    end
    update_agent(user)
  end

  # Caching feeds

  @doc """
    Cache the entire feed for all users. Includes RSS sources and followed users.

    Loops trough all users in the database and runs `cache/1` for each. It also caches all RSS sources using Cachex.
  """
  def cache_feeds() do
    cache_rss_feeds()
    cache_user_feeds()
  end

  def get_feed(url) do
    {:ok, feed} = Cachex.get(:rss, url)
    feed
  end

  @doc """
    Cache the entire feed for a single user.

    Loops trough all sources and followed users and caches their items using Nindo.FeedAgent
    Can be called on its own, but is almost always called when starting Nindo via cache_feeds/1
  """
  def cache(user) do
    username = user.username
    feeds = user.feeds

    if feeds != nil do
      {:ok, pid} =
        DynamicSupervisor.start_child(
          Nindo.Supervisor,
          FeedAgent.child_spec(username)
        )

        FeedAgent.add_user(username, pid)
        FeedAgent.update(pid)
    end
  end

  @deprecated "Use update_cache/1 instead"
  def update_agent(user), do: update_cache(user)

  @doc """
    Update cached feed for user.

    Gets the PID from FeedAgent and updates the FeedAgent feed using it.
    Called when changes to sources are made, and just when the feed needs to reload.
  """
  def update_cache(user) do
    Task.async(fn ->
      user
      |> FeedAgent.get_pid()
      |> FeedAgent.update()
    end)
  end

  # Private methods

  defp cache_user_feeds() do
    # Start lookup table for user feeds
    DynamicSupervisor.start_child(
        Nindo.Supervisor,
        FeedAgent.child_spec()
    )

    Database.list(Account)
    |> Enum.map(fn user -> Task.async(fn ->
      cache(user)
    end) end)
    |> Task.await_many(:infinity)
  end

  defp cache_rss_feeds() do
    for user <- Database.list(Account) do
      Enum.map(user.feeds, fn source -> Task.async(fn ->
          feed = RSS.parse_feed(source["feed"], source["type"])

          items =
            Enum.map(feed["items"], fn entry ->
              {{source["feed"], entry["title"], entry["pub_date"]}, entry}
            end)

          Cachex.put(:rss, source["feed"], feed)
          Cachex.put_many(:rss, items)
        end)
      end)
    end
  end

  defp empty_to_nil(map) do
    map
    |> Enum.map(fn
      {key, val} when val === "" -> {key, nil}
      {key, val} -> {key, val}
    end)
    |> Enum.into(%{})
  end

end
