defmodule Nwiki.MixProject do
  use Mix.Project

  def project do
    [
      app: :nwiki,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: Nwiki.CLI]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false},
      {:credo, "~> 1.1", only: :dev, runtime: false},
      {:earmark, "~> 1.4"},
      {:earmark_hashed_link, github: "niku/earmark_hashed_link"},
      {:earmark_raw_html, github: "niku/earmark_raw_html"}
    ]
  end
end
