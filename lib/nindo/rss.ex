defmodule Nindo.RSS do
  @moduledoc false

  alias Nindo.{Accounts, Posts, Feeds, Format}
  alias Nindo.RSS.YouTube
  import Nindo.Core

  # Methods to parse feeds

  @deprecated "use detect_feed/2 instead"
  def detect_feed(source) do
    "https://" <> source <> "/feeds/posts/default?alt=rss"
  end

  def detect_feed("blogger", source),     do: "https://" <> source <> "/feeds/posts/default?alt=rss&max-results=5"
  def detect_feed("wordpress", source),   do: "https://" <> source <> "/feed/"
  def detect_feed("youtube", source) do
    [_, _, channel] = String.split(source, "/")
    atom_to_rss("https://www.youtube.com/feeds/videos.xml?channel_id=#{channel}")
  end
  def detect_feed("atom", source),        do: atom_to_rss("https://" <> source)
  def detect_feed(_, source),             do: "https://" <> source

  def detect_favicon(source) do
    "https://" <> source <> "/favicon.ico"
  end

  def parse_feed(source) do
    case HTTPoison.get(source) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case FastRSS.parse(body) do
          {:ok, feed} -> feed
          error -> error
        end
      error -> error
    end
  end

  def generate_posts(feed) do
    Enum.map(feed["items"], fn entry ->
      %{
        author: feed["title"],
        body: HtmlSanitizeEx.basic_html(entry["description"]) |> safe(),
        datetime: from_rfc822(entry["pub_date"]),
        image: entry["media"]["thumbnail"]["attrs"]["url"],
        title: entry["title"],
        link: entry["link"],
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

  def atom_to_rss(source) do
    "https://feedmix.novaclic.com/atom2rss.php?source=" <> URI.encode(source)
  end

  # Methods to construct Nindo feeds

  def fetch_posts({username, _, _}) do
    account = Accounts.get_by(:username, username)
    sources = Feeds.get(account)

    posts =
      sources
      |> Enum.map(fn source -> Task.async(fn ->

        source
        |> parse_feed()
        |> generate_posts()

      end) end)
      |> Task.await_many()
      |> List.flatten()
      |> Enum.sort_by(&(&1.datetime), {:desc, NaiveDateTime})

    {username, sources, posts}
  end

  # Methods to handle YT api stuff

  defmodule YouTube do
    @moduledoc false

    @key "AIzaSyCDm7TOdKFCZPEzPcPR9OPu_DwcR9TzYOk"

    def to_channel_link(url) do
      [_, type, channel] = String.split(url, "/")

      channel_id =
        case type do
          "c" -> YouTube.get_from_custom(url)
          "user" -> YouTube.get_from_username(channel)
          _ -> channel
        end

      "www.youtube.com/channel/#{channel_id}"
    end

    def get_from_custom(source) do
      data = parse_json("https://youtube.googleapis.com/youtube/v3/search?q=#{source}&part=id&type=channel&fields=items(id(kind,channelId))&max_results=1&key=#{@key}")
      hd(data["items"])["id"]["channelId"]
    end

    def get_from_username(username) do
      data = parse_json("https://www.googleapis.com/youtube/v3/channels?forUsername=#{username}&part=id&key=#{@key}")
      hd(data["items"])["id"]
    end

    def parse_json(source) do
      case HTTPoison.get(source) do
        {:ok, %HTTPoison.Response{body: body}} ->
          case Jason.decode(body) do
            {:ok, data} -> data
            error -> error
          end
        error -> error
      end
    end

  end

end
