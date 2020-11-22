defmodule Lynx.Text do
  @moduledoc """
  Utility functions for turning text into links.

  """

  import Lynx, only: [get_config: 3]

  alias Lynx.Parser
  alias Lynx.Formatter

  def extract(text, opts \\ []) when is_binary(text) do
    formatter = get_config(:formatter, opts, Lynx.Formatter)

    extracted = Enum.flat_map parse(text, opts), fn
      {type, _} = elem ->
        [{type, formatter.format(elem)}]

      _otherwise ->
        []
    end

    Enum.group_by(extracted, &elem(&1, 0), &elem(&1, 1))
  end

  @doc """
  Parses, formats, and returns all links in a text.

  ## Examples

      iex> Lynx.Text.extract_links("link to www.example.com!")
      ["http://www.example.com"]

      iex> Lynx.Text.extract_links("link to www.example.com and test.com/some/path")
      ["http://www.example.com", "http://test.com/some/path"]

  """
  def extract_links(text) when is_binary(text),
    do: do_extract(Parser.strategy(:link), text, [])

  @doc false
  defp do_extract({type, _} = strategy, text, acc) do
    Enum.flat_map do_parse(strategy, text, acc), fn
      {^type, _} = elem ->
        [Formatter.format(elem)]

      _otherwise ->
        []
    end
  end

  @doc """
  Parses out all values based on available parsing strategies, strategies take
  precedence in the list order.

  ## Examples

      iex> Lynx.Text.parse("link to www.example.com!")
      ["link to ", {:link, "www.example.com"}, "!"]

      iex> Lynx.Text.parse("link to www.example.com and test.com/some/path")
      ["link to ", {:link, "www.example.com"}, " and ", {:link, "test.com/some/path"}]

      iex> Lynx.Text.parse("link to www.example.com and mention @example", parser: LynxTest.ParserWithMentions)
      ["link to ", {:link, "www.example.com"}, " and mention ", {:mention, "@example"}]

  """
  def parse(text, opts \\ []) when is_binary(text) do
    parser = get_config(:parser, opts, Lynx.Parser)

    Enum.reduce parser.strategies(), [text], fn strategy, acc ->
      Enum.flat_map acc, fn
        {_, _} = elem ->
          [elem]

        unparsed_text ->
          do_parse(strategy, unparsed_text, [])
      end
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
  def parse_links(text) when is_binary(text),
    do: do_parse(Parser.strategy(:link), text, [])

  @doc false
  defp do_parse(_strategy, "", acc), do: Enum.reverse(acc)

  defp do_parse({key, match} = strategy, text, acc) do
    case Regex.run(match, text, return: :index) do
      nil ->
        Enum.reverse([text | acc])

      [{0, _length} = indexes | _rest] ->
        {nil, link, rest} = parse_from_indexes(text, indexes)

        do_parse(strategy, rest, [{key, link} | acc])

      [{_start_index, _length} = indexes | _rest] ->
        {before, link, rest} = parse_from_indexes(text, indexes)

        do_parse(strategy, rest, [{key, link}, before | acc])
    end
  end

  @doc false
  defp parse_from_indexes(text, {start_index, length}) do
    end_index = start_index + length
    before = if start_index != 0, do: Kernel.binary_part(text, 0, start_index)
    link = Kernel.binary_part(text, start_index, length)
    rest = Kernel.binary_part(text, end_index, Kernel.byte_size(text) - end_index)
    {before, link, rest}
  end
end
