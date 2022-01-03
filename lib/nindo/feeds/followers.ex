defmodule Nindo.Followers do
  @moduledoc false

  alias Nindo.{Accounts}

  def add(username, user) do
    following = user.following
    if username not in following do
      Accounts.change(:following, [username | following], user)
    end
  end

  def remove(username, user) do
    following = user.following
    if username in following do
      Accounts.change(:following, following -- [username], user)
    end
  end
end
