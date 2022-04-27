defmodule Nindo.Posts do
  @moduledoc false

  alias NinDB.{Database, Post}
  import Nindo.Core

  def new(title, body, image, user) do
    %{author_id: user.id, title: title, body: body, image: image, datetime: datetime()}
    |> Database.put(Post)
  end

  def get(id) do
    Database.get(Post, id)
  end

  def get_latest(limit) do
    Database.list(Post, limit)
  end

  def get_by_author(author_id) do
    Database.get_by(:author, Post, author_id)
  end

  def exists?(id) do
    get(id) !== nil
  end
end
