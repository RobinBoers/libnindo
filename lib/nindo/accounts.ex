defmodule Nindo.Accounts do
  @moduledoc false

  alias NinDB.{Account, Database}
  alias Nindo.{Auth}

  def new(username, password, email) do
    password = Auth.hash_pass(password)

    %Account{username: username, password: password, email: email}
    |> Database.put()
  end

  def login(username, password) do
    case check_login(username, password) do
      true -> :logged_in
      false -> :wrong_password
    end
  end

  defp check_login(username, password) do
    hash_db = Database.get_by_username(Account, username).password
    Auth.verify_pass(password, hash_db)
  end
end
