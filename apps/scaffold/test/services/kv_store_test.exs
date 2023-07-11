defmodule Scaffold.Services.StoreTest do
  use ExUnit.Case, async: true

  def read_definition(filename) do
    path = Path.expand("../../../lib/services", __ENV__.file)
    File.read!("#{path}/#{filename}")
  end

  setup do
    {:ok, "kv-store"} = Octopus.define(read_definition("kv-store.json"))
    {:ok, _state} = Octopus.start("kv-store")

    on_exit(fn -> Octopus.delete("kv-store") end)
  end

  test "set and get" do
    assert {:ok, %{"ok" => "ok"}} =
             Octopus.call("kv-store", "set", %{"key" => "foo", "value" => "bar"})

    assert {:ok, %{"value" => "bar"}} = Octopus.call("kv-store", "get", %{"key" => "foo"})
  end
end
