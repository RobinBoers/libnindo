defmodule Nindo.Core do
  @moduledoc false

  def datetime() do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end
end
