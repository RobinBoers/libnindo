defmodule Nindo.Posts do
  @moduledoc false

  alias NinDB.{Database, Post}
  alias Nindo.{Accounts}
  import Nindo.Core

  def new(title, body, image \\ nil, logged_in \\ logged_in())
  def new(_, _, _, false), do: {:error, "Not logged in. "}

  def new(title, body, image, true) do
    %Post{author_id: user.id, title: title, body: body, image: image, like_count: 0, comments: %{}, datetime: datetime()}
    |> Database.put(Post)
  end

  def get(id) do
    Database.get(Post, id)
  end

  def get(:user, author_id) do
    Database.get_by_author(Post, author_id)
  end
  def get(:newest, limit) do
    Database.get_all(Post, limit)
  end

  def like(id, logged_in \\ logged_in())
  def like(_, false), do: {:error, "Not logged in. "}

  def like(id, true) do
    case is_liked(id) do
      true -> :already_liked
      false ->
        change_like_count(id, 1)
        change_liked(id, :add)
    end
  end

  def dislike(id, logged_in \\ logged_in())
  def dislike(_, false), do: {:error, "Not logged in. "}

  def dislike(id, true) do
    case is_liked(id) do
      true ->
        change_liked(id, :rem)
        change_like_count(id, -1)
      _ -> :ok
    end
  end

  # Private methods

  defp change_like_count(post_id, amount) do
    post = get(post_id)
    current_likes = post.like_count
    Database.update(post, :like_count, current_likes + amount)
  end

  defp is_liked(id), do: Enum.member?(Accounts.get(user.id).liked, id)
  defp get_liked(user_id), do: Accounts.get(user_id).liked

  defp change_liked(id, :add), do: Accounts.change(:liked, get_liked(user.id) ++ [id])
  defp change_liked(id, :rem), do: Accounts.change(:liked, get_liked(user.id) -- [id])

end
