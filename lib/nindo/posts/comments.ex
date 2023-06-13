defmodule Nindo.Comments do
  @moduledoc false

  alias NinDB.{Comment, Database}
  import Nindo.Core

  def new(id, title, body, user, parent \\ nil) do
    %{
      post_id: id,
      author_id: user.id,
      parent: parent,
      title: title,
      body: body,
      datetime: datetime()
    }
    |> Database.put(Comment)
  end

  def reply(comment_id, title, body, user) do
    comment = get(comment_id)
    new(comment.post_id, title, body, user)
  end

  def get(comment_id) do
    Database.get(Comment, comment_id)
  end

  def get_by_author(author_id) do
    Database.get_by(:author, Comment, author_id)
  end

  def get_by_parent(parent_id) do
    Database.get_by(:parent, Comment, parent_id)
  end

  def get_by_post(post_id) do
    Database.get_by(:post, Comment, post_id)
  end
end
