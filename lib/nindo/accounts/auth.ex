defmodule Nindo.Auth do
  @moduledoc """
    Authenticate users

    This module is used to validate user passwords using Bcrypt. It can hash and verify passwords, and also has a handy method to get the salt used by Bcrypt, to also store that in the database.
  """

  def get_salt(),                 do: Bcrypt.gen_salt()
  def hash_pass(password, salt),  do: Bcrypt.Base.hash_password(password, salt)

  def verify_pass(password, salt, hash) do
    hash_pass(password, salt) == hash
  end

end
