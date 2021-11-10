defmodule Nindo.Friends do
  @moduledoc false

  alias NinDB.{Database, Friend}

  def add(id, user) do
    %Friend{friend_id: id, user_id: user.id}
    |> Database.put(Friend)
  end

  def get(id) do
    Database.get(Friend, id)
  end

  def list_for(user_id) do
    Database.get_by(:user_id, Friend, user_id)
  end

  def list_from(friend_id) do
    Database.get_by(:friend, Friend, friend_id)
  end

end
