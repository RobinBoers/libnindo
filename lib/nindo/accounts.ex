defmodule Nindo.Accounts do
  @moduledoc """
    Manage Nindo accounts

  ## Account struct

    Every account is a `NinDB.Account` struct with these properties:

    | item           | key          | description                                                                      |
    |----------------|--------------|----------------------------------------------------------------------------------|
    | Username       | username     | Unique identifier. All lowercase, no spaces.                                     |
    | Display name   | display_name | Your name. `nil` by default. Can contain spaces and unicode chars.               |
    | Biography      | description  | Your biography. Can also contain unicode chars and spaces.                       |
    | Emailaddress   | email        | Valid and unique emailaddress. Encrypted using `Cloak`.                          |
    | Sources        | sources      | List of sources for your feed. Empty by default. Uses the `NinDB.Source` struct. |
    | Followed users | following    | List of the usernames of users you follow. Empty by default.                     |
    | Password       | password     | Your password encrypted using `Bcrypt`.                                          |
    | Bcrypt salt    | salt         | Salt used to encrypt your password.                                              |
  """

  alias NinDB.{Account, Database}
  alias Nindo.{Auth}

  @doc """
    Create a new account

    Every username is unique. It should be all lowercase characters and no spaces. The email also has to be unique. If no profile picture is given a default one will be generated using [DiceBear](https://avatars.dicebear.com).

    Returns either `{:ok, account}` or `{:error, changeset}`

  ## Examples

      iex> Nindo.Accounts.new("robin", "b0b", "robin@geheimesite.nl")
      {:ok, %NinDB.Account{}}
  """
  def new(username, password, email, image \\ nil) do
    username = String.trim username
    password = String.trim password

    salt = Auth.get_salt()
    password = Auth.hash_pass(password, salt)

    %{username: username, password: password, email: email, salt: salt, profile_picture: image, feeds: []}
    |> Database.put(Account)
  end

  @doc """
    Login to an account

    Given an username and password, try to log into the account. Returns either `:ok`, `:wrong_password` or `:no_user_found`.
  """
  def login(username, password) do
    case check_login(username, password) do
      true -> :ok
      false -> :wrong_password
      _ -> :no_user_found
    end
  end

  @doc """
    Get account by ID

    Given an ID, get that account from the database.

  ## Examples

      iex> Nindo.Accounts.get(13)
      %NinDB.Account{}
  """
  def get(id) do
    Database.get(Account, id)
  end

  @doc """
    Get account by specific property

  ## Available properties

    - Username (`:username`)

  ## Examples

        iex> Nindo.Accounts.get_by(:username, "robin")
        %NinDB.Account{}
  """
  def get_by(:username, username) do
    Database.get_by(:username, Account, username)
  end

  @doc """
    Get a list of accounts

    Given either a limit or `:infinity`, get a list of users from the database. Returns a list of users.

  ## Examples

      iex> Nindo.Accounts.list(1)
      [%NinDB.Account{}]
  """
  def list(:infinity) do
    Database.list(Account)
  end
  def list(limit) do
    Database.list(Account, limit)
  end

  @doc """
    Search users

    Search the database for users. Has one parameter: a query. Checks for all users in the database if their username, display name or description contains the query. Search for specific usernames by prefixing your search with "@".

  ## Examples

      iex> Nindo.Accounts.search("@robin")
      [%NinDB.Account{}]
  """
  def search(query) do
    Account
    |> Database.list()
    |> Enum.filter(fn account ->
      cond do
        account.username != nil and String.contains?(account.username, query) -> true
        String.first(query) == "@" and account.username == String.slice(query, 1..-1) -> true
        account.description != nil and String.contains?(String.downcase(account.description), query) -> true
        account.display_name != nil and String.contains?(String.downcase(account.display_name), query) -> true
        true -> false
      end
    end)
  end

  @doc """
    Update user preferences

    Change key in the database (used to update prefs). Returns either `{:ok, account}` or `{:error, changeset}`.

  ## Examples

      iex> import Nindo.Core
      iex> Nindo.Accounts.change(:display_name, "Robin Boers", user())
  """
  def change(key, value, user) do
    Account
    |> Database.get(user.id)
    |> Database.update(key, value)
  end

  @doc """
    Check if account exists

    Given an username, check if an account with that username exists. Returns either true of false.

  ## Examples

      iex> Nindo.Accounts.exists?("robin")
      true
  """
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
