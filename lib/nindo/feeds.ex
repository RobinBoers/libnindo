defmodule Nindo.Feeds do
  @moduledoc """
    Manage sources and RSS feeds

    This module handles all feed/source related stuff:

    - Add/remove sources
    - Follow/unfollow users
    - Caching

  ## Feeds

    The sources itself are stored in in a list that is stored under the `:feeds` key in the database. It can look a bit like this:

      [
        %{
          "feed" => "webdevelopment-en-meer.blogspot.com",
          "icon" => "https://webdevelopment-en-meer.blogspot.com/favicon.ico",
          "title" => "Webdevelopment-En-Meer",
          "type" => "blogger"
        }
      ]

    Every source has:

    - **Feed:** the URI to the blog or site of the feed
    - **Icon:** the URI to the favicon for that site
    - **Title:** the title/name of the feed
    - **Type:** the feed type (either blogger, youtube, wordpress, atom or custom)

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

    The caching itself is done in `Nindo.RSS.fetch_posts/1` and `Nindo.RSS.generate_posts/2`.
  """

  alias Nindo.{Accounts, FeedAgent}
  alias NinDB.{Database, Account}

  def add(feed, user) do
    feeds = user.feeds
    if feed not in feeds do
      Accounts.change(:feeds, [feed | feeds], user)
    end
    update_cache(user)
  end

  def remove(feed, user) do
    feed = empty_to_nil(feed)
    feeds = user.feeds
    if feed in feeds do
      Accounts.change(:feeds, feeds -- [feed], user)
    end
    update_cache(user)
  end

  def follow(person, user) do
    following = user.following
    if person not in following do
      Accounts.change(:following, [person | following], user)
    end
    update_cache(user)
  end

  def unfollow(person, user) do
    following = user.following
    if person in following do
      Accounts.change(:following, following -- [person], user)
    end
    update_cache(user)
  end

  # Caching feeds

  @doc """
    Cache the entire feed for all users. Includes RSS sources and followed users.

    Loops trough all users in the database and runs `cache/1` for each. It also caches all RSS sources using Cachex.
  """
  def cache_feeds() do
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

  ## Caching user feeds

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

  ## Caching external feeds

  @doc """
    Get parsed feed from cache

    Takes a URI and gets the parsed feed from the cache.
  """
  def get_feed(url) do
    {:ok, feed} = Cachex.get(:rss, url)
    feed
  end

  @doc """
    Get post from cache

    Takes a URI, title and datetime and returns a map that resembles the `NinDB.Post` struct.
  """
  def get_post(url, title, datetime) do
    {:ok, post} = Cachex.get(:rss, {url, title, datetime})
    post
  end

  # Private methods

  defp empty_to_nil(map) do
    map
    |> Enum.map(fn
      {key, val} when val === "" -> {key, nil}
      {key, val} -> {key, val}
    end)
    |> Enum.into(%{})
  end

end
