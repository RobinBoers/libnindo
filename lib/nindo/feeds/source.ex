defmodule Nindo.Source do
  @moduledoc false

  @derive Jason.Encoder
  defstruct id: 1, feed: nil, icon: "/images/rss.png", title: nil, type: "custom"

  def from_map(%{"feed" => feed, "icon" => icon, "title" => title, "type" => type}) do
    %__MODULE__{feed: feed, icon: icon, title: title, type: type}
  end
end
