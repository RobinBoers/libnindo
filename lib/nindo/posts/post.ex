defmodule Nindo.Post do
  @moduledoc false

  @behaviour Access

  alias NinDB.Source
  import Nindo.Core

  defstruct author: "Unknown",
            id: nil,
            body: nil,
            datetime: datetime(),
            image: nil,
            title: nil,
            link: nil,
            type: "custom",
            source: %Source{}

  @impl Access
  def fetch(struct, key), do: Map.fetch(struct, key)

  if Version.compare(System.version(), "1.7.0") == :lt do
    @impl Access
  end

  def get(struct, key, default \\ nil) do
    case struct do
      %{^key => value} -> value
      _else -> default
    end
  end

  def put(struct, key, val) do
    if Map.has_key?(struct, key) do
      Map.put(struct, key, val)
    else
      struct
    end
  end

  def delete(struct, key) do
    put(struct, key, struct(__MODULE__)[key])
  end

  @impl Access
  def get_and_update(struct, key, fun) when is_function(fun, 1) do
    current = get(struct, key)

    case fun.(current) do
      {get, update} ->
        {get, put(struct, key, update)}

      :pop ->
        {current, delete(struct, key)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{
                inspect(other)
              }"
    end
  end

  @impl Access
  def pop(struct, key, default \\ nil) do
    val = get(struct, key, default)
    updated = delete(struct, key)
    {val, updated}
  end
end
