defmodule ScaffoldTest do
  use ExUnit.Case
  doctest Scaffold

  test "greets the world" do
    assert Scaffold.hello() == :world
  end
end
