defmodule Nindo.Feeds do
  @moduledoc false

  alias Nindo.{Accounts, FeedAgent, RSS}
  alias NinDB.{Database, Account}

  def add(feed, user) do
    feeds = user.feeds
    if feed not in feeds do
      Accounts.change(:feeds, [feed | feeds], user)
    end
  end

  def remove(feed, user) do
    feed = empty_to_nil(feed)
    feeds = user.feeds
    if feed in feeds do
      Accounts.change(:feeds, feeds -- [feed], user)
    end
  end

  def get(user) do
    user.feeds
    |> Enum.map(fn feed ->
      RSS.detect_feed(feed["type"], feed["feed"])
    end)
  end

  # Caching feeds

  def cache_feed() do
    # Start lookup table for user feeds
    DynamicSupervisor.start_child(
        Nindo.Supervisor,
        FeedAgent.child_spec()
    )

    Database.list(Account)
    |> Enum.each(fn user -> cache(user) end)
  end

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
