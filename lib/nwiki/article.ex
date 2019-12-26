defmodule Nwiki.Article do
  defstruct name: nil, body: nil, links: Map.new(), linked: Map.new()
end
