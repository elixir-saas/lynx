defmodule Lynx.LinkPreview.DiffbotClient do
  use HTTPoison.Base

  @behaviour Lynx.LinkPreview.Client

  @default_opts [recv_timeout: 35_000]
  @base_url "https://api.diffbot.com/v3"
  @article_fields ["icon", "images", "pageUrl", "siteName", "text", "title"]

  @impl true
  def get_link_preview(url) do
    query = URI.encode_query %{
      url: url,
      token: Lynx.fetch_config!(:client, :api_token, []),
      fields: Enum.join(@article_fields, ",")
    }

    get("/article?" <> query)
    |> handle_response()
    |> parse_link_preview()
  end

  def parse_link_preview(response) do
    case response do
      {:ok, [result | _rest]} ->
        %{
          page_title: result["title"],
          page_description: result["text"],
          page_site_name: result["siteName"],
          page_url: result["page_url"],
          page_icon_url: result["icon_url"],
          page_image_url: get_result_image(result)
        }

      {:error, _reason} = error ->
        error
    end
  end

  def get_result_image(result) do
    result
    |> Map.get("images", [])
    |> Enum.find_value(& &1["primary"] && &1["url"])
  end

  def handle_response({:ok, %HTTPoison.Response{body: %{"objects" => objects}, status_code: 200}}), do: {:ok, objects}
  def handle_response({:ok, %HTTPoison.Response{body: %{"error" => _error}, status_code: 200}}), do: {:error, :target_site_error}
  def handle_response({:ok, %HTTPoison.Response{}}), do: {:error, :api_server_error}
  def handle_response({:error, %HTTPoison.Error{reason: :timeout}}), do: {:error, :timeout}

  @impl true
  def process_request_url(url), do: @base_url <> url

  @impl true
  def process_request_options(opts), do: Keyword.merge(@default_opts, opts)

  @impl true
  def process_response_body(body), do: Jason.decode!(body)
end
