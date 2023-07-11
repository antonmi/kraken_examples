defmodule Scaffold.Pipelines.Hello.Test do
  use ExUnit.Case

  def read_service_definition(filename) do
    path = Path.expand("../../../../lib/kraken/services", __ENV__.file)
    File.read!("#{path}/#{filename}")
  end

  def read_pipeline_definition(filename) do
    path = Path.expand("../../../../lib/kraken/pipelines", __ENV__.file)
    File.read!("#{path}/#{filename}")
  end

  def read_routes_definition() do
    path = Path.expand("../../../../lib/kraken", __ENV__.file)
    File.read!("#{path}/routes.json")
  end

  setup do
    Kraken.Services.define(read_service_definition("greeter.json"))
    Kraken.Services.start("greeter")
    Kraken.Services.define(read_service_definition("kv-store.json"))
    Kraken.Services.start("kv-store")
    Kraken.Pipelines.define(read_pipeline_definition("hello.json"))
    Kraken.Pipelines.start("hello")
    Kraken.Routes.define(read_routes_definition())

    on_exit(fn ->
      Kraken.Services.delete("greeter")
      Kraken.Services.delete("kv-store")
      Kraken.Pipelines.delete("hello")
    end)
  end

  test "calls the pipeline" do
    event = %{"type" => "hello", "name" => "Anton"}
    result = Kraken.call(event)
    assert result["message"] == "Hello, Anton!"

    result = Kraken.call(event)
    assert result["message"] == "I've already said hello to you, Anton."
  end
end
