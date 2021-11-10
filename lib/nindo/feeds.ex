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
    feeds = user.feeds
    if feed in feeds do
      Accounts.change(:feeds, feeds -- [feed], user)
    end
  end

end
