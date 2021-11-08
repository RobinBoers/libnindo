defmodule Nindo.Posts do
  @moduledoc false

  alias NinDB.{Database, Post}
  alias Nindo.{Accounts}
  import Nindo.Core

  def new(title, body, image \\ nil, logged_in \\ logged_in())
  def new(_, _, _, false), do: {:error, "Not logged in. "}

  def new(title, body, image, true) do
    %Post{author_id: user.id, title: title, body: body, image: image, datetime: datetime()}
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

end
