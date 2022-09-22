defmodule Lynx.LinkPreview.Client do
  @doc """
  Fetches link preview metadata for a URL. If successful, returns a map of
  fields to be cast into a chnageset.

  """
  @callback get_link_preview(String.t()) :: {:ok, term} | {:error, term}
end
