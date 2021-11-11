defmodule Nindo.Feeds do
  @moduledoc false

  alias Nindo.{Accounts}

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
