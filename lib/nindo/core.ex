defmodule Nindo.Core do
  @moduledoc false

  alias Nindo.{Agent}

  def logged_in(), do: Agent.get(:logged_in)
  def user(), do: Agent.get(:user)

  def datetime() do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end
end
