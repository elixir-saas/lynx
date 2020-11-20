defmodule Lynx.LinkPreview.OpenGraphClient do
  use HTTPoison.Base

  @default_opts [recv_timeout: 15_000, follow_redirect: true]

  def get_link_preview(url) do
    get(url)
    |> handle_response()
    |> parse_link_preview()
  end

  def parse_link_preview(response) do
    case response do
      {:ok, document} ->
        %{
          page_title: og_attr(document, "title"),
          page_description: og_attr(document, "description"),
          page_site_name: og_attr(document, "site_name"),
          page_url: og_attr(document, "url"),
          page_image_url: og_attr(document, "image")
        }

      {:error, _reason} = error ->
        error
    end
  end

  defp og_attr(document, name) do
    document
    |> Floki.find(~s(head meta[property="og:#{name}"]))
    |> Floki.attribute("content")
    |> Enum.at(0, nil)
  end

  defp handle_response({:ok, %HTTPoison.Response{body: document, status_code: 200}}), do: {:ok, document}
  defp handle_response({:ok, %HTTPoison.Response{}}), do: {:error, :target_site_error}
  defp handle_response({:error, %HTTPoison.Error{reason: :timeout}}), do: {:error, :timeout}

  @impl true
  def process_request_options(opts), do: Keyword.merge(@default_opts, opts)

  @impl true
  def process_response_body(body), do: Floki.parse_document!(body)
end
