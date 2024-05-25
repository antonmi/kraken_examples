defmodule Github.MixProject do
  use Mix.Project

  def project do
    [
      app: :github,
      version: "0.1.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kraken, "0.3.4"},
      {:octopus_client_http_finch, "0.2.1"},
      {:levenshtein, "0.3.0"}
    ]
  end
end
