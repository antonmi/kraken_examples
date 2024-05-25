defmodule PipelineTest do
  use ExUnit.Case
  use Plug.Test
  doctest Github
  alias Kraken.Api.Router

  @path Path.expand("../..", __ENV__.file) <> "/lib"

  setup do
    on_exit(fn ->
      Kraken.Services.delete("github")
      Kraken.Services.delete("levenshtein")
      Kraken.Pipelines.delete("levenshtein")
    end)
  end

  def define_and_start_github_service do
    service_json = File.read!("#{@path}/github_service.json")

    conn =
      :post
      |> conn("/services/define", service_json)
      |> Router.call(%{})

    assert conn.resp_body == "{\"ok\":\"github\"}"

    conn =
      :post
      |> conn("/services/start/github")
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\""

    conn =
      :post
      |> conn("/services/call/github/find_users", Jason.encode!(%{"query" => "antonmi"}))
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\":{\"total_count\":"
  end

  def define_and_start_levenshtein_service do
    service_json = File.read!("#{@path}/levenshtein_service.json")

    conn =
      :post
      |> conn("/services/define", service_json)
      |> Router.call(%{})

    assert conn.resp_body == "{\"ok\":\"levenshtein\"}"

    conn =
      :post
      |> conn("/services/start/levenshtein")
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\""
  end

  def define_and_start_clone_service do
    service_json = File.read!("#{@path}/clone_service.json")

    conn =
      :post
      |> conn("/services/define", service_json)
      |> Router.call(%{})

    assert conn.resp_body == "{\"ok\":\"clone-service\"}"

    conn =
      :post
      |> conn("/services/start/clone-service")
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\""

    conn =
      :post
      |> conn(
        "/services/call/clone-service/clone",
        Jason.encode!(%{"event" => %{"a" => 1}, "memo" => nil})
      )
      |> Router.call(%{})

    assert conn.resp_body ==
             "{\"ok\":{\"events\":[{\"a\":1},{\"a\":1,\"report\":true}],\"memo\":null}}"
  end

  def define_and_start_io_inspect_service do
    service_json = File.read!("#{@path}/io_inspect_service.json")

    conn =
      :post
      |> conn("/services/define", service_json)
      |> Router.call(%{})

    assert conn.resp_body == "{\"ok\":\"io-inspect\"}"

    conn =
      :post
      |> conn("/services/start/io-inspect")
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\""

    conn =
      :post
      |> conn(
           "/services/call/io-inspect/print",
           Jason.encode!(%{"value" => "Hello!"})
         )
      |> Router.call(%{})

    assert conn.resp_body == "{\"ok\":{\"value\":\"Hello!\"}}"
  end

  def define_and_start_pipeline do
    pipeline_json = File.read!("#{@path}/pipeline.json")

    conn =
      :post
      |> conn("/pipelines/define", pipeline_json)
      |> Router.call(%{})

    assert conn.resp_body == "{\"ok\":\"stream-similar-followers\"}"

    conn =
      :post
      |> conn("/pipelines/start/stream-similar-followers")
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\""
  end

  def define_route do
    payload = Jason.encode!(%{"similar-followers": "stream-similar-followers"})

    conn =
      :post
      |> conn("/routes/define", payload)
      |> Router.call(%{})

    assert conn.resp_body =~ "{\"ok\""
  end

  test "pipeline call" do
    define_and_start_github_service()
    define_and_start_levenshtein_service()
    define_and_start_clone_service()
    define_and_start_io_inspect_service()
    define_and_start_pipeline()
    define_route()

    event =
      Jason.encode!(%{
        type: "similar-followers",
        query: "antonmi",
        limit: 3
      })

    conn =
      :post
      |> conn("/call", event)
      |> Router.call(%{})

    records = Jason.decode!(conn.resp_body)

    assert %{
             "counter" => 1,
             "limit" => 3,
             "query" => "antonmi",
             "user_data" => %{
               "company" => "Kloeckner.i",
               "followers" => _followers,
               "location" => "Berlin",
               "name" => "Anton Mishchuk",
               "username" => "antonmi"
             },
             "username" => "antonmi"
           } = hd(records)
  end
end
