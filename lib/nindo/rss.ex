defmodule Nindo.RSS do
  @moduledoc false

  alias Nindo.{Format}

  import Nindo.Core

  def base_url(), do: Application.get_env(:nindo, :base_url)

  def generate_channel(user) do
    RSS.channel(
      "#{Format.display_name(user)}'s feed · Nindo",
      "https://#{base_url()}/user/#{user.username}",
      user.description,
      to_rfc822(datetime()),
      "en-us"
    )
  end

  def generate_entries(user) do
    :user
    |> Posts.get(user.id)
    |> Enum.reverse()
    |> Enum.map(&generate_entry(&1.title, &1.body, &1.datetime, &1.id))
  end

  def generate_entry(title, body, datetime, id) do
    RSS.item(
      title,
      markdown(body),
      to_rfc822(datetime),
      "https://#{base_url()}/post/#{id}",
      "https://#{base_url()}/post/#{id}"
    )
  end

  defdelegate generate_feed(channel, items), to: RSS, as: :feed
end
