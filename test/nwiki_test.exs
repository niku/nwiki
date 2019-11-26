defmodule NwikiTest do
  use ExUnit.Case
  doctest Nwiki

  test "greets the world" do
    assert Nwiki.hello() == :world
  end
end
