defmodule KrakenInitTest do
  use ExUnit.Case
  doctest KrakenInit

  test "greets the world" do
    assert KrakenInit.hello() == :world
  end
end
