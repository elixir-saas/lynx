defmodule Lynx.Text do
  @moduledoc """
  Utility functions for turning text into links.

  """

  @match_link ~r{(?<url>(?:https?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~%:\/?#[\]@!\$&'\(\)\*\+,;=.]+[\w\-_\/?&\+])}u

  @doc """
  Parses, formats, and returns all links in a text.

  ## Examples

    iex> Lynx.Text.extract_links("link to www.example.com!")
    ["http://www.example.com"]

    iex> Lynx.Text.extract_links("link to www.example.com and test.com/some/path")
    ["http://www.example.com", "http://test.com/some/path"]

  """
  def extract_links(text) when is_binary(text) do
    Enum.flat_map parse_links(text), fn
      {:link, link} ->
        [format_link(link)]

      _otherwise ->
        []
    end
  end

  @doc """
  Locates all links in a binary and returns the full unmodified text as a list
  with links wrapped in a tagged tuple.

  ## Examples

    iex> Lynx.Text.parse_links("link to www.example.com!")
    ["link to ", {:link, "www.example.com"}, "!"]

    iex> Lynx.Text.parse_links("link to www.example.com and test.com/some/path")
    ["link to ", {:link, "www.example.com"}, " and ", {:link, "test.com/some/path"}]

  """
  def parse_links(text) when is_binary(text), do: do_parse(text, [])

  defp do_parse("", acc), do: Enum.reverse(acc)

  defp do_parse(text, acc) do
    case Regex.run(@match_link, text, return: :index) do
      nil ->
        Enum.reverse([text | acc])

      [{0, _length} = indexes | _rest] ->
        {nil, link, rest} = parse_from_indexes(text, indexes)

        do_parse(rest, [{:link, link} | acc])

      [{_start_index, _length} = indexes | _rest] ->
        {before, link, rest} = parse_from_indexes(text, indexes)

        do_parse(rest, [{:link, link}, before | acc])
    end
  end

  defp parse_from_indexes(text, {start_index, length}) do
    end_index = start_index + length
    before = if start_index != 0, do: Kernel.binary_part(text, 0, start_index)
    link = Kernel.binary_part(text, start_index, length)
    rest = Kernel.binary_part(text, end_index, Kernel.byte_size(text) - end_index)
    {before, link, rest}
  end

  def format_link(link = "http://" <> _), do: link
  def format_link(link = "https://" <> _), do: link
  def format_link(link), do: "http://" <> link
end
