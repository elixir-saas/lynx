defmodule Lynx.Formatter do
  @moduledoc """
  Formatting functions for parsed type-value tuples.

  """

  def format({:link, link = "http://" <> _}), do: link
  def format({:link, link = "https://" <> _}), do: link
  def format({:link, link}), do: "http://" <> link

  def format({_type, value}), do: value
end
