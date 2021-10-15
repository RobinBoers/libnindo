defmodule Nindo.Agent do
  @moduledoc false

  @me __MODULE__

  def start_link(account) do
    Agent.start_link(account, name: @me)
  end

  def get_session() do
    Agent.get(@me, fn x -> x end)
  end
end
