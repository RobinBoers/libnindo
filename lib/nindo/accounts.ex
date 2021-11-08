defmodule Nindo.Accounts do
  @moduledoc false

  alias NinDB.{Account, Database}
  alias Nindo.{Auth, Agent}
  import Nindo.Core

  def new(username, password, email) do
    username = String.trim username
    password = String.trim password

    salt = Auth.get_salt()
    password = Auth.hash_pass(password, salt)

    %Account{username: username, password: password, email: email, salt: salt}
    |> Database.put(Account)
  end

  def login(username, password) do
    case check_login(username, password) do
      true -> start_agent(username)
      false -> :wrong_password
    end
  end

  def logout(), do: Agent.put(:logout)

  def get(id) do
    Database.get(Account, id)
  end

  def get_by(:username, username) do
    Database.get_by(:username, Account, username)
  end

  def list(limit) do
    Database.get_all(Account, limit)
  end

  def change(key, value, logged_in \\ logged_in())
  def change(_, _, false), do: {:error, "Not logged in."}

  def change(key, value, true) do
    Database.get(Account, user.id)
    |> Database.update(key, value)
    update_agent()
  end

  def exists(username), do: user_exists(username)

  # Private methods

  defp check_login(username, password) do
    case user_exists(username) do
      true -> check_pass(username, password)
      false -> :no_user_found
    end
  end

  defp user_exists(username), do: Database.get_by(:username, Account, username) != nil

  defp check_pass(username, password) do
    hash_db = Database.get_by(:username, Account, username).password
    salt = Database.get_by(:username, Account, username).salt

    Auth.verify_pass(password, salt, hash_db)
  end

  defp start_agent(username) do
    Database.get_by(:username, Account, username)
    |> Agent.put()
  end

  defp update_agent() do
    Database.get(Account, user.id)
    |> Agent.put()
  end
end
