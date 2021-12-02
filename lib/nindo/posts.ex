defmodule Nindo.Posts do
  @moduledoc """
    Create and manage posts
  """

  alias NinDB.{Database, Post}
  import Nindo.Core

  def new(title, body, image, user) do
    %{author_id: user.id, title: title, body: body, image: image, datetime: datetime()}
    |> Database.put(Post)
  end

  def get(id) do
    Database.get(Post, id)
  end

  @doc """
    Get posts by specific property.

    Get posts from the database by either author_id or datetime.

  ## Examples

      iex> Nindo.Posts.get(:user, 13)
      iex> Nindo.Posts.get(:latest, 50)
      iex> Nindo.Posts.get(:newest, 30)

  """
  def get(:user, author_id) do
    Database.get_by(:author, Post, author_id)
  end
  def get(:latest, limit), do: get(:newest, limit)
  def get(:newest, limit) do
    Database.list(Post, limit)
  end

  def exists?(id), do: get(id) !== nil

end
