defmodule Nindo.Comments do
  @moduledoc false

  alias NinDB.{Comment, Database}
  import Nindo.Core

  def new(id, title, body, parent \\ nil, logged_in \\ logged_in())
  def new(_, _, _, _, false), do: {:error, "Not logged in."}

  def new(id, title, body, parent, true) do
    %Comment{post_id: id, author_id: user.id, parent: parent, title: title, body: body, datetime: datetime()}
    |> Database.put(Comment)
  end

  def reply(comment_id, title, body, logged_in \\ logged_in())
  def reply(_, _, _, false), do: {:error, "Not logged in. "}

  def reply(comment_id, title, body, true) do
    comment = get(comment_id)
    new(comment.post_id, title, body)
  end

  def get(id) do
    Database.get(Comment, id)
  end
  def get(:user, id) do
    Database.get_by(:author, Comment, id)
  end
  def get(:parent, id) do
    Database.get_by(:parent, Comment, id)
  end
  def get(:post, id) do
    Database.get_by(:post, Comment, id)
  end

end
