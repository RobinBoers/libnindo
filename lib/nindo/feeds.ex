defmodule Nindo.Feeds do
  @moduledoc """
    Manage sources and RSS feeds

    This module handles all feed/source related stuff:

    - Add/remove sources
    - Follow/unfollow users
    - Caching

  ## Caching

    Caching can be split up into two catagories:

    - User feeds
    - Sources

  ### User feeds

    User feeds are the feeds that users can construct themselves and appear on their homepage. They consist of sources and followed users/accounts. User feeds are cached using `Nindo.FeedAgent`.

  ### External/RSS feeds

    External feeds are the sources displayed in the homepage feed, but as standalone feeds. They can be viewed by clicking on a source in the sources tab. For each external feed added, both the entire parsed feed and every post alone will be cached.

    The entire feed will be cached using Cachex with the URI as key. The standalone posts are saved with a tuple as key:

    `{url, title, datetime}`

    Where the datetime is an Elixir naive datetime.
  """

  alias Nindo.{Accounts, FeedAgent, RSS}
  alias NinDB.{Database, Account}

  import Nindo.Core

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
    cache_user_feeds()
    cache_rss_feeds()
  end

  ## Caching user feeds

  @doc """
    Cache the entire feed for a single user.

    Loops trough all sources and followed users and caches their items using Nindo.FeedAgent
    Can be called on its own, but is almost always called when starting Nindo via cache_feeds/1
  """
  def cache_user(user) do
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

  ## Caching external feeds

  def get_feed(url) do
    {:ok, feed} = Cachex.get(:rss, url)
    feed
  end

  def get_post(url, title, datetime) do
    {:ok, post} = Cachex.get(:rss, {url, title, datetime})
    post
  end

  @doc """
    Cache a source.

    Caches all individual posts and also the entire parsed XML feed using Cachex.
  """
  def cache_source(source) do
    feed = RSS.parse_feed(source["feed"], source["type"])

    items =
      Enum.map(feed["items"], fn entry ->
        {
          {source["feed"], entry["title"], from_rfc822(entry["pub_date"])},
          RSS.generate_post(feed, source, entry)
        }
      end)

    Cachex.put(:rss, source["feed"], feed)
    Cachex.put_many(:rss, items)
  end

  # Private methods

  defp cache_user_feeds() do
    DynamicSupervisor.start_child(
        Nindo.Supervisor,
        FeedAgent.child_spec()
    )

    Database.list(Account)
    |> Enum.map(fn user -> Task.async(fn ->
      cache_user(user)
    end) end)
    |> Task.await_many(:infinity)
  end

  defp cache_rss_feeds() do
    for user <- Database.list(Account) do
      Enum.map(user.feeds, fn source -> Task.async(fn ->
          cache_source(source)
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
