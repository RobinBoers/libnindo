defmodule Nindo.Accounts do
  @moduledoc false

  alias NinDB.{Account, Database}
  alias Nindo.{Auth, Agent}
  import Nindo.Core

  # Internal implementation of public API

  def new(username, password, email) do
    password = Auth.hash_pass(password)

    %Account{username: username, password: password, email: email}
    |> Database.put(Account)
  end

  def login(username, password) do
    case check_login(username, password) do
      true -> start_agent(username)
      false -> {:error, "Login failed. You either entered a wrong password or the account you're trying to access doens't exist. "}
    end
  end

  def logout(), do: Agent.put(:logout)

  def get(id) do
    Database.get(Account, id)
  end

  def change(key, value, logged_in \\ logged_in())
  def change(_, _, false), do: {:error, "Not logged in."}

  def change(key, value, true) do
    Database.get(Account, user.id)
    |> Database.update(key, value)
    update_agent()
  end

  # Private methods

  defp check_login(username, password) do
    hash_db = Database.get_by_username(Account, username).password
    Auth.verify_pass(password, hash_db)
  end

  defp start_agent(username) do
    Database.get_by_username(Account, username)
    |> Agent.put()
  end

  defp update_agent() do
    Database.get(Account, user.id)
    |> Agent.put()
  end
end
