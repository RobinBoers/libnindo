defmodule Nindo.Auth do
  @moduledoc false

  def hash_pass(password) do
    :sha256
    |> :crypto.hash(password)
    |> Base.encode16()
  end

  def verify_pass(password, hash) do
    hash_pass(password) == hash
  end

end
