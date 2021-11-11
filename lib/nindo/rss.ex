defmodule Nindo.RSS do
  @moduledoc false

  alias Nindo.{Posts, Format}
  import Nindo.Core

  # Methods to parse feeds

  def detect_feed(source) do
    "https://" <> source <> "/feeds/posts/default?alt=rss"
  end

  def parse_feed(source) do
    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(source)
    {:ok, feed, _} = FeederEx.parse(body)

    feed
  end

  def generate_posts(feed) do
    Enum.map(feed.entries, fn entry ->
      %{
        author: entry.author,
        body: safe(entry.summary),
        datetime: datetime(),
        image: entry.image,
        title: entry.title,
      }
    end)
  end

  # Methods to generate feeds

  def generate_channel(user) do
    RSS.channel(
      "#{Format.display_name(user.username)}'s feed · Nindo",
      "https://nindo.net/user/#{user.username}",
      user.description,
      to_rfc822(datetime()),
      "en-us"
    )
  end

  def generate_entries(user) do
    :user
    |> Posts.get(user.id)
    |> Enum.map(fn post ->
      RSS.item(
        post.title,
        post.body,
        to_rfc822(post.datetime),
        "https://nindo.net/post/#{post.id}",
        "https://nindo.net/post/#{post.id}"
      )
    end)
  end

  defdelegate generate_feed(channel, items), to: RSS, as: :feed



end
