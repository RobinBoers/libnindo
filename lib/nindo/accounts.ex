defmodule Nindo.Accounts do
  @moduledoc false

  alias NinDB.{Account, Database}
  alias Nindo.{Auth}

  def new(username, password, email, image \\ nil) do
    username = String.trim(username)
    password = String.trim(password)

    salt = Auth.get_salt()
    password = Auth.hash_pass(password, salt)

    %{
      username: username,
      password: password,
      email: email,
      salt: salt,
      profile_picture: image,
      feeds: []
    }
    |> Database.put(Account)
  end

  def login(username, password) do
    case exists?(username) do
      true -> password_valid?(username, password)
      _ -> {:error, :no_user_found}
    end
  end

  def get(id) do
    Database.get(Account, id)
  end

  def get_by_username(username) do
    Database.get_by(:username, Account, username)
  end

  def exists?(username) do
    get_by_username(username) != nil
  end

  def list() do
    Database.list(Account)
  end

  def list(limit) do
    Database.list(Account, limit)
  end

  def change(key, value, user) do
    Account
    |> Database.get(user.id)
    |> Database.update(key, value)
  end

  def search(query) do
    Account
    |> Database.list()
    |> Enum.filter(&search_matches?(&1, query))
  end

  defp password_valid?(username, password) do
    account = get_by_username(username)
    hash_db = account.password
    salt = account.salt

    case Auth.verify_pass(password, salt, hash_db) do
      true -> {:ok, account}
      false -> {:error, :password_incorrect}
    end
  end

  defp search_matches?(account, query) do
    cond do
      exact_match_with_at_sign?(account.username, query) -> true
      username_contains_query?(account.username, query) -> true
      description_contains_query?(account.description, query) -> true
      display_name_contains_query?(account.display_name, query) -> true
      true -> false
    end
  end

  defp exact_match_with_at_sign?(username, query) do
    String.first(query) == "@" and username == String.slice(query, 1..-1)
  end

  defp username_contains_query?(username, query) do
    String.contains?(username, query)
  end

  defp description_contains_query?(nil, _query), do: false

  defp description_contains_query?(description, query) do
    description != nil and String.contains?(String.downcase(description), query)
  end

  defp display_name_contains_query?(nil, _query), do: false

  defp display_name_contains_query?(display_name, query) do
    display_name != nil and String.contains?(String.downcase(display_name), query)
  end
end
