defmodule LevenshteinServiceTest do
  use ExUnit.Case
  use Plug.Test
  doctest Github
  alias Kraken.Api.Router

  setup do
    on_exit(fn ->
      Kraken.Services.delete("levenshtein")
    end)
  end

  def define_and_start_service do
    path = Path.expand("../..", __ENV__.file) <> "/lib"
    service_json = File.read!("#{path}/levenshtein_service.json")

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

  test "closest" do
    define_and_start_service()

    args = Jason.encode!(%{"name" => "anton", "names" => ["bread", "baton", "salat"]})

    conn =
      :post
      |> conn("/services/call/levenshtein/closest", args)
      |> Router.call(%{})

    assert %{"ok" => %{"closest" => "baton"}} = Jason.decode!(conn.resp_body)
  end
end
