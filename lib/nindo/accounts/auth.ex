defmodule Nindo.Auth do
  @moduledoc false

  def get_salt(),                 do: Bcrypt.gen_salt()
  def hash_pass(password, salt),  do: Bcrypt.Base.hash_password(password, salt)

  def verify_pass(password, salt, hash) do
    hash_pass(password, salt) == hash
  end

end
