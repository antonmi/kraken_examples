defmodule Scaffold.Services.GreeterTest do
  use ExUnit.Case, async: true

  def read_definition(filename) do
    path = Path.expand("../../../../lib/kraken/services", __ENV__.file)
    File.read!("#{path}/#{filename}")
  end

  setup do
    {:ok, "greeter"} = Octopus.define(read_definition("greeter.json"))
    {:ok, _state} = Octopus.start("greeter")

    on_exit(fn -> Octopus.delete("greeter") end)
  end

  test "greet" do
    assert {:ok, %{"message" => "Hello, Anton!"}} =
             Octopus.call("greeter", "greet", %{"name" => "Anton"})
  end

  test "no_greet" do
    assert {:ok, %{"message" => "I've already said hello to you, Anton."}} =
             Octopus.call("greeter", "no_greet", %{"name" => "Anton"})
  end
end
