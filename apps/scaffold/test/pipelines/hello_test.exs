defmodule Scaffold.Pipelines.Hello.Test do
  use ExUnit.Case

  def read_service_definition(filename) do
    path = Path.expand("../../../lib/services", __ENV__.file)
    File.read!("#{path}/#{filename}")
  end

  def read_pipeline_definition(filename) do
    path = Path.expand("../../../lib/pipelines", __ENV__.file)
    File.read!("#{path}/#{filename}")
  end

  setup do
    Kraken.Services.define(read_service_definition("greeter.json"))
    Kraken.Services.start("greeter")
    Kraken.Services.define(read_service_definition("kv-store.json"))
    Kraken.Services.start("kv-store")
    Kraken.Pipelines.define(read_pipeline_definition("hello.json"))
    Kraken.Pipelines.start("hello")

    on_exit(fn ->
      Kraken.Services.delete("greeter")
      Kraken.Services.delete("kv-store")
      Kraken.Pipelines.delete("hello")
    end)
  end

  test "calls the pipeline" do
    result = Kraken.Pipelines.call("hello", %{"name" => "Anton"})
    assert result["message"] == "Hello, Anton!"

    result = Kraken.Pipelines.call("hello", %{"name" => "Anton"})
    assert result["message"] == "I've already said hello to you, Anton."
  end
end
