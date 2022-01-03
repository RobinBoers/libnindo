defmodule Nindo.Sources do
  @moduledoc false

  alias NinDB.{Source}
  alias Nindo.{Accounts, Post}

  import Nindo.Core

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

  # we're only generating and caching the first five posts due to performance issues
  def generate_posts(parsed_feed, source) do
    parsed_feed["items"]
    |> Enum.take(5) # remove to get entire feed
    |> Enum.map(&Task.async(generate_post(&1, parsed_feed["title"], source)))
    |> Task.await_many(30000)
  end

  def generate_post(entry, author, source) do
    %Post{
      author: author,
      body: HtmlSanitizeEx.basic_html(entry["description"]),
      id: :erlang.phash2(entry["title"]),
      datetime: from_rfc822(entry["pub_date"]),
      image: entry["media"]["thumbnail"]["attrs"]["url"],
      title: entry["title"],
      link: entry["link"],
      type: source.type,
      source: source
    }
  end
end
