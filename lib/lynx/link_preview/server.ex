defmodule Lynx.LinkPreview.Server do
  use GenServer

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def submit_resource(resource, opts \\ [])

  def submit_resource({:ok, resource}, opts) do
    {:ok, submit_resource(resource, opts)}
  end

  def submit_resource(resource = %_Schema{}, opts) do
    links = resource
    |> Map.fetch!(Keyword.get(opts, :field, :text))
    |> Lynx.Text.extract_links()

    GenServer.cast(__MODULE__, {:links, links, resource})
    resource
  end

  def submit_resource(value, _opts), do: value

  @impl true
  def init(opts) do
    {:ok, %{
      context_module: Lynx.fetch_config!(:context_module, opts),
      client_strategy: Lynx.fetch_config!(:client, :strategy, opts),
      tasks: []
    }}
  end

  @impl true
  def handle_cast({:links, links, resource}, state = %{context_module: context}) do
    link_previews = context.list_link_previews(resource)

    existing_links = Enum.map(link_previews, & &1.link)
    removable_links = existing_links -- links
    new_links = links -- existing_links

    Logger.info("Processing links, #{length existing_links} existing, #{length removable_links} to remove, #{length new_links} to add")

    if not Enum.empty?(removable_links) do
      context.delete_link_previews(resource, links: removable_links)
    end

    tasks = Enum.flat_map new_links, fn link ->
      case context.create_link_preview(link, resource) do
        {:ok, link_preview} ->
          Logger.debug("Created link preview: #{inspect link_preview}")
          [Task.async(__MODULE__, :fetch_link_preview_telemetry, [link_preview, state])]

        {:error, reason} ->
          Logger.error("Error while creating link preview: #{inspect reason}")
          []
      end
    end

    {:noreply, %{state | tasks: state.tasks ++ tasks}}
  end

  def fetch_link_preview_telemetry(link_preview, state) do
    :telemetry.span(
      [:lynx, :fetch_link_preview],
      %{link: link_preview.link},
      fn -> {fetch_link_preview(link_preview, state), %{}} end
    )
  end

  def fetch_link_preview(link_preview, %{context_module: context, client_strategy: client}) do
    case client.get_link_preview(link_preview.link) do
      nil ->
        Logger.warn("Failed to look up article data for link preview #{inspect link_preview}")
        context.update_link_preview_failed(link_preview)

      link_details ->
        case context.update_link_preview_loaded(link_preview, link_details) do
          {:ok, link_preview} ->
            Logger.info("Persisted article data for link preview #{inspect link_preview}")

          {:error, reason} ->
            Logger.info("Failed to persist article data for link preview #{inspect link_preview}, reason: #{inspect reason}")
            context.delete_link_preview(link_preview)
        end
    end
    :processed
  end

  @impl true
  def handle_info({ref, :processed}, state) when is_reference(ref) do
    {:noreply, %{state | tasks: Enum.reject(state.tasks, & &1.ref == ref)}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, :normal}, state) do
    {:noreply, %{state | tasks: Enum.reject(state.tasks, & &1.ref == ref)}}
  end

  @impl true
  def terminate(_reason, state) do
    Enum.each(state.tasks, &Task.await/1)
  end
end
