defmodule Nindo.Feeds do
  @moduledoc false

  alias Nindo.{Accounts}
  import Nindo.Core

  def add(feed, logged_in \\ logged_in())
  def add(_, false), do: {:error, "Not logged in."}

  def add(feed, true) do
    feeds = Accounts.get(user.id).feeds
    if feed not in feeds do
      Accounts.change(:feeds, [feed | feeds])
    end
  end

  def remove(feed, logged_in \\ logged_in())
  def remove(_, false), do: {:error, "Not logged in."}

  def remove(feed, true) do
    feeds = Accounts.get(user.id).feeds
    if feed in feeds do
      Accounts.change(:feeds, feeds -- [feed])
    end
  end

end
