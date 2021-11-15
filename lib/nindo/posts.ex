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

  def get(:user, author_id) do
    Database.get_by(:author, Post, author_id)
  end
  def get(:newest, limit) do
    Database.get_all(Post, limit)
  end

  def exists?(id), do: get(id) !== nil

end
