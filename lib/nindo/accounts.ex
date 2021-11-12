defmodule Nindo.Accounts do
  @moduledoc false

  alias NinDB.{Account, Database}
  alias Nindo.{Auth}

  def new(username, password, email, image \\ nil) do
    username = String.trim username
    password = String.trim password

    salt = Auth.get_salt()
    password = Auth.hash_pass(password, salt)

    %{username: username, password: password, email: email, salt: salt, profile_picture: image, feeds: []}
    |> Database.put(Account)
  end

  def login(username, password) do
    case check_login(username, password) do
      true -> :ok
      false -> :wrong_password
    end
  end

  def get(id) do
    Database.get(Account, id)
  end

  def get_by(:username, username) do
    Database.get_by(:username, Account, username)
  end

  def list(limit) do
    Database.get_all(Account, limit)
  end

  def change(key, value, user) do
    Account
    |> Database.get(user.id)
    |> Database.update(key, value)
  end

  def exists?(username), do: user_exists(username)

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

end
