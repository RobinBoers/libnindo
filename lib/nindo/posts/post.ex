defmodule Nindo.Post do
  @moduledoc false

  alias NinDB.Source
  import Nindo.Core

  defstruct author: "Unknown",
            body: nil,
            datetime: datetime(),
            image: nil,
            title: nil,
            link: nil,
            type: "custom",
            source: %Source{}
end
