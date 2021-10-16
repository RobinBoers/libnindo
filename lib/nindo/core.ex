defmodule Nindo.Core do
  @moduledoc false

  alias Nindo.{Agent}

  def logged_in(), do: Agent.get(:logged_in)
  def user(), do: Agent.get(:user)
end
