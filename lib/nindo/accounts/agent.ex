defmodule Nindo.Agent do
  @moduledoc false

  @me __MODULE__

  def start_link() do
    Agent.start_link(&init_state/0, name: @me)
  end

  def get(:logged_in) do
    Agent.get(@me, fn {logged_in, _} -> logged_in end)
  end

  def get(:user) do
    Agent.get(@me, fn {_, user} -> user end)
  end

  def put(:logout) do
    Agent.update(@me, fn _state -> init_state() end)
  end
  def put(account) do
    Agent.update(@me, fn _state -> set_state(account) end)
  end

  # Private methods

  defp init_state(), do: {false, nil}
  defp set_state(account), do: {true, account}
end
