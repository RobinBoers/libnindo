defmodule Nindo.Posts do
  @moduledoc false

  alias NinDB.{Database, Post}
  import Nindo.Core

  def new(title, body, image \\ nil, logged_in \\ logged_in())
  def new(_, _, _, false), do: {:error, "Not logged in. "}

  def new(title, body, image, true) do
    %Post{author_id: user.id, title: title, body: body, image: image, like_count: 0, comments: %{}}
    |> Database.put(Post)
  end

end
