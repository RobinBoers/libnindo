defmodule Nindo.Posts do
  @moduledoc """
    Create and manage posts
  """

  alias NinDB.{Database, Post}
  import Nindo.Core

  @doc """
    Create new post

    Write a post and publish it.

  ## Examples

      iex> import Nindo.Core
      iex> Nindo.Posts.new("Example post", "Lorem ipsum dolor sit amet.", nil, user())
      {:ok, %NinDB.Post{}}
  """
  def new(title, body, image, user) do
    %{author_id: user.id, title: title, body: body, image: image, datetime: datetime()}
    |> Database.put(Post)
  end

  @doc """
    Get a post by its ID

  ## Examples

      iex> Nindo.Posts.get(7)
      %NinDB.Post{}
  """
  def get(id) do
    Database.get(Post, id)
  end

  @doc """
    Get posts by specific property

    Get posts from the database by either author_id or datetime.

    Note that `:latest` and `:newest` do the same thing, but `:latest` is preferred as `:newest` is deprecated.

  ## Examples

      iex> Nindo.Posts.get(:user, 13)
      iex> Nindo.Posts.get(:latest, 50)
      iex> Nindo.Posts.get(:newest, 30)
  """
  def get(:user, author_id) do
    Database.get_by(:author, Post, author_id)
  end
  def get(:newest, limit), do: get(:latest, limit)
  def get(:latest, limit) do
    Database.list(Post, limit)
  end

  @doc """
    Check if posts exists

    Given a ID, check if that posts exists. Returns either true or false.

  ## Examples

      iex> Nindo.Posts.exists?(1)
      false
  """
  def exists?(id), do: get(id) !== nil

end
