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
