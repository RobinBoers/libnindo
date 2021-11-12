defmodule Nindo.Comments do
  @moduledoc false

  alias NinDB.{Comment, Database}
  import Nindo.Core

  def new(id, title, body, user, parent \\ nil) do
    %{post_id: id, author_id: user.id, parent: parent, title: title, body: body, datetime: datetime()}
    |> Database.put(Comment)
  end

  def reply(comment_id, title, body, user) do
    comment = get(comment_id)
    new(comment.post_id, title, body, user)
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
