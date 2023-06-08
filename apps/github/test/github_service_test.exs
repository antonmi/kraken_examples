defmodule GithubServiceTest do
  use ExUnit.Case
  use Plug.Test
  doctest Github
  alias Kraken.Api.Router

  setup do
    on_exit(fn ->
      Kraken.Services.delete("github")
    end)
  end

  def define_and_start_service do
    path = Path.expand("../..", __ENV__.file) <> "/lib"
    service_json = File.read!("#{path}/github_service.json")

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

  test "greets the world" do
    define_and_start_service()

    args = Jason.encode!(%{"query" => "antonmi", "per_page" => 1})

    conn =
      :post
      |> conn("/services/call/github/find_users", args)
      |> Router.call(%{})

    assert %{"ok" => %{"total_count" => _count, "usernames" => ["antonmi"]}} =
             Jason.decode!(conn.resp_body)

    args = Jason.encode!(%{"username" => "antonmi"})

    conn =
      :post
      |> conn("/services/call/github/get_user", args)
      |> Router.call(%{})

    assert %{
             "ok" => %{
               "company" => "Kloeckner.i",
               "location" => "Berlin",
               "name" => "Anton Mishchuk",
               "followers" => _followers,
               "username" => "antonmi"
             }
           } = Jason.decode!(conn.resp_body)

    args = Jason.encode!(%{"username" => "antonmi", "per_page" => 100})

    conn =
      :post
      |> conn("/services/call/github/get_followers", args)
      |> Router.call(%{})

    assert %{
             "ok" => %{
               "followers" => list
             }
           } = Jason.decode!(conn.resp_body)

    assert length(list) == 100
  end
end
