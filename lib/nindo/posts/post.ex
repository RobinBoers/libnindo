defmodule Nindo.Post do
  @moduledoc false

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

  def generate(entry, author, source) do
    %__MODULE__{
      author: author,
      body: HtmlSanitizeEx.basic_html(entry["description"]),
      id: :erlang.phash2(entry["title"]),
      datetime: from_rfc822(entry["pub_date"]),
      image: entry["media"]["thumbnail"]["attrs"]["url"],
      title: entry["title"],
      link: entry["link"],
      type: source.type,
      source: source
    }
  end
end
