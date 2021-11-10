defmodule Nindo.Feeds do
  @moduledoc false

  alias Nindo.{Accounts}

  def add(feed, user) do
    feeds = Accounts.get(user.id).feeds
    if feed not in feeds do
      Accounts.change(:feeds, [feed | feeds], user.id)
    end
  end

  def remove(feed, user) do
    feeds = Accounts.get(user.id).feeds
    if feed in feeds do
      Accounts.change(:feeds, feeds -- [feed], user.id)
    end
  end

end
