defmodule Nindo.Feeds do
  @moduledoc false

  alias Nindo.{Accounts, Posts, YouTube, Sources}

  @empty_feed %{"title" => "Unknown feed", "items" => []}

  def detect(type, url) do
    case type do
      :blogger   -> "https://#{url}/feeds/posts/default?alt=rss&max-results=5"
      :wordpress -> "https://#{url}/feed/"
      :youtube   -> atom YouTube.rss_feed(url)
      :atom      -> atom "https://#{url}"
      _          -> "https://#{url}"
    end
  end

  defp atom(source) do
    "https://feedmix.novaclic.com/atom2rss.php?source=" <> URI.encode(source)
  end

  @spec parse(String.t()) :: map | {:error, any()}
  def parse(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case FastRSS.parse(body) do
          {:ok, feed} -> feed
          error -> error
        end
      error -> error
    end
  end

  def fetch(user) do
    rss_posts = fetch_external(user.sources)
    user_posts = fetch_users(user.following)

    [user_posts | rss_posts]
    |> Enum.sort_by(&(&1.datetime), {:desc, NaiveDateTime})
  end

  defp fetch_external(sources) do
    sources
    |> Enum.map(fn source -> Task.async(fn ->
      url = detect(source.feed, source.type)

      feed = case parse(url) do
        {:error, _} -> @empty_feed
        f -> f
      end

      Sources.generate_posts(feed, source)

    end) end)
    |> Task.await_many(30000)
    |> List.flatten()
  end

  defp fetch_users(following) do
    following
    |> Enum.map(fn username -> Task.async(fn ->
      account = Accounts.get_by_username(username)
      posts = Posts.get_by_author(account.id)

      Enum.map(posts, &Map.from_struct(&1))

    end) end)
    |> Task.await_many(30000)
    |> List.flatten()
  end
end
