defmodule Nindo.YouTube do
  @moduledoc false

  defp key() do
    System.get_env("YT_KEY")
  end

  def instance() do
    Application.get_env(:nindo, :invidious_instance)
  end

  def rss_feed(url) do
    [_youtube, _channel, channel_id] = String.split(url, "/")
    "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
  end

  def to_channel_link(url) do
    [_youtube, type, channel] = String.split(url, "/")

    channel_id =
      case type do
        "c" -> get_id_from_custom(url)
        "user" -> get_id_from_username(channel)
        _ -> channel
      end

    "www.youtube.com/channel/#{channel_id}"
  end

  defp get_id_from_custom(source) do
    data =
      parse_json(
        "https://youtube.googleapis.com/youtube/v3/search?q=#{source}&part=id&type=channel&fields=items(id(kind,channelId))&max_results=1&key=#{key()}"
      )

    hd(data["items"])["id"]["channelId"]
  end

  defp get_id_from_username(username) do
    data =
      parse_json(
        "https://www.googleapis.com/youtube/v3/channels?forUsername=#{username}&part=id&key=#{key()}"
      )

    hd(data["items"])["id"]
  end

  defp parse_json(source) do
    case HTTPoison.get(source) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> data
          error -> error
        end

      error ->
        error
    end
  end
end
