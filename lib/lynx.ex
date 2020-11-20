defmodule Lynx do
  @moduledoc """
  Documentation for `Lynx`.

  """

  def fetch_config!(key, opts) do
    with :error <- Keyword.fetch(opts, key),
         :error <- Application.fetch_env(:lynx, key) do
      raise "Lynx is missing a config value: #{inspect key}"
    else
      {:ok, value} -> value
    end
  end

  def fetch_config!(key, nested_key, opts) do
    config = fetch_config!(key, opts)

    with :error <- Keyword.fetch(config, nested_key) do
      raise "Lynx is missing a config value: #{inspect [key, nested_key]}"
    else
      {:ok, value} -> value
    end
  end
end
