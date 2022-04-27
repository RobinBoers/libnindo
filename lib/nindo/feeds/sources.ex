defmodule Nindo.Sources do
  @moduledoc false

  alias NinDB.{Source}
  alias Nindo.{Accounts, Post}

  def add(source, user) do
    sources = user.sources
    if source not in sources do
      Accounts.change(:sources, sources ++ [source], user)
    end
  end

  def remove(source, user) do
    sources = user.sources
    if source in sources do
      Accounts.change(:sources, sources -- [source], user)
    end
  end

  def generate(title, type, url) do
    %Source{
      title: title,
      id: :erlang.phash2(url),
      feed: url,
      type: type,
      icon: "https://#{url}/favicon.ico"
    }
  end

  def generate_posts(parsed_feed, source) do
    parsed_feed["items"]
    # we're only generating and caching the first five posts due to performance issues
    # remove Enum.take(5) to get entire feed
    |> Enum.take(5)
    |> Enum.map(&Task.async(Post.generate(&1, parsed_feed["title"], source)))
    |> Task.await_many(30000)
  end
end
