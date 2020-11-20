defmodule Lynx.LinkPreview do
  @moduledoc """
  Utility functions for working with link previews.

  """

  @doc """
  Accepts a list of before-links and after-links, which represent the state of
  links associated with a single resource, and returns a list of new links (to
  be created) and a list of removable links (to be deleted).

  """
  def diff_links(current_links, next_links) do
    new_links = next_links -- current_links
    removable_links = current_links -- next_links
    {new_links, removable_links}
  end
end
