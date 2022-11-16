defmodule SmartForm.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_form,
      version: "0.1.0",
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
      {:phoenix_html, ">= 3.2.0"},
      {:ecto, ">= 3.9.1"},
      {:ecto_sqlite3, "~> 0.8.2", only: [:dev, :test]}
    ]
  end
end
