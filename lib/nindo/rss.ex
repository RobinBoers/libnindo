defmodule Nindo.RSS do
  @moduledoc false

  alias Nindo.{Accounts, Posts, Format}
  alias Nindo.RSS.YouTube
  import Nindo.Core

  @default_source %{"type" => "custom", "icon" => "/images/rss.png"}

  # Methods to parse feeds

  @deprecated "use detect_feed/2 instead"
  def detect_feed(url) do
    "https://" <> url <> "/feeds/posts/default?alt=rss"
  end

  def detect_feed("blogger", url),     do: "https://" <> url <> "/feeds/posts/default?alt=rss&max-results=5"
  def detect_feed("wordpress", url),   do: "https://" <> url <> "/feed/"
  def detect_feed("youtube", url) do
    [_, _, channel] = String.split(url, "/")
    atom_to_rss("https://www.youtube.com/feeds/videos.xml?channel_id=#{channel}")
  end
  def detect_feed("atom", url),        do: atom_to_rss("https://" <> url)
  def detect_feed(_, url),             do: "https://" <> url

  def detect_favicon(url) do
    "https://" <> url <> "/favicon.ico"
  end

  def parse_feed(url, type) do
    url = detect_feed(type, url)
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case FastRSS.parse(body) do
          {:ok, feed} -> feed
          error -> error
        end
      error -> error
    end
  end

  def generate_posts(feed, source \\ @default_source) do
    feed["items"]
    |> Enum.map(fn entry -> Task.async(fn ->
        %{
          author: feed["title"],
          body: HtmlSanitizeEx.no_images(entry["description"]),
          datetime: from_rfc822(entry["pub_date"]),
          image: entry["media"]["thumbnail"]["attrs"]["url"],
          title: entry["title"],
          link: entry["link"],
          type: source["type"],
          source: source
        }
      end)
    end)
    |> Task.await_many(30000)
  end

  def atom_to_rss(source) do
    "https://feedmix.novaclic.com/atom2rss.php?source=" <> URI.encode(source)
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

  # Methods to construct Nindo feeds

  def fetch_posts({username, _}) do
    account = Accounts.get_by(:username, username)

    rss_posts =
      account.feeds
      |> Enum.map(fn source -> Task.async(fn ->

        source["feed"]
        |> parse_feed(source["type"])
        |> generate_posts(source)

      end) end)
      |> Task.await_many(30000)
      |> List.flatten()

    user_posts =
      account.following
      |> Enum.map(fn username -> Task.async(fn ->

        account = Accounts.get_by(:username, username)
        posts = Posts.get(:user, account.id)

        Enum.map(posts, fn post ->
          Map.from_struct(post)
        end)

      end) end)
      |> Task.await_many(30000)
      |> List.flatten()

    posts =
      user_posts ++ rss_posts
      |> Enum.sort_by(&(&1.datetime), {:desc, NaiveDateTime})

    {username, posts}
  end

  def generate_source(feed, type, url) do
    %{
      "title" => feed["title"],
      "feed" => url,
      "type" => type,
      "icon" => detect_favicon(
        URI.parse("https://" <> url).authority
      )
    }
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
