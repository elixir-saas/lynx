defmodule Lynx.HTML do
  import Phoenix.HTML.Tag, only: [content_tag: 3]
  import Lynx.Text, only: [parse_links: 1, format_link: 1]

  @doc """
  Parses links from a binary and changes them to anchor tags. Returns iodata,
  with parsed links marked as :safe.

  Options:

    * `:link_attrs` - attributes to pass to the anchor tag
    * `:process_href` - a function to process the href of the anchor
    * `:process_text` - a function to process the text content of the anchor

  The `process_href` option is particularly useful for automatically generating
  exit links, which take the user through a backend redirect before leaving
  your site:

    linkify_text "link to example.com",
      process_href: & Routes.page_path(@conn, :exit, url: &1)

  """
  def linkify_text(text, opts \\ []) when is_binary(text) do
    link_attrs = Keyword.get(opts, :link_attrs, [])
    process_href = Keyword.get(opts, :process_href, & &1)
    process_text = Keyword.get(opts, :process_text, & &1)

    Enum.map parse_links(text), fn
      {:link, link} ->
        attrs = Keyword.put(link_attrs, :href, process_href.(format_link(link)))
        content_tag :a, attrs, do: process_text.(link)

      text ->
        text
    end
  end
end
