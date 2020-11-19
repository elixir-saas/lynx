  alias <%= inspect schema.module %>

  @doc """
  Returns the list of <%= schema.singular %> for a particular resource.

  ## Examples

    iex> list_<%= schema.plural %>(resource)
    [%<%= inspect schema.alias %>{}, %<%= inspect schema.alias %>{}]

  """
  def list_<%= schema.plural %>(resource = %_Schema{}) do
    Repo.all from l in <%= inspect schema.alias %>,
      where: [resource_id: ^resource.id]
  end

  @doc """
  Creates a new <%= schema.singular %> for a resource in a loading state.

  ## Examples

    iex> create_<%= schema.singular %>!(link, resource)
    %<%= inspect schema.alias %>{}

  """
  def create_<%= schema.singular %>!(link, resource = %_Schema{}) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(%{link: link, resource_id: resource.id})
    |> Repo.insert!()
    |> <%= inspect pub_sub.alias %>.<%= pub_sub.broadcast %>(:created)
  end

  @doc """
  Updates a <%= schema.singular %> when it has been successfully loaded.

  ## Examples

    iex> update_<%= schema.singular %>_loaded!(<%= schema.singular %>, attrs)
    %<%= inspect schema.alias %>{}

  """
  def update_<%= schema.singular %>_loaded!(<%= schema.singular %> = %<%= inspect schema.alias %>{}, attrs) do
    <%= schema.singular %>
    |> <%= inspect schema.alias %>.loaded_changeset(attrs)
    |> Repo.update!()
    |> <%= inspect pub_sub.alias %>.<%= pub_sub.broadcast %>(:updated)
  end

  @doc """
  Updates a <%= schema.singular %> when it has failed to load.

  ## Examples

    iex> update_<%= schema.singular %>_failed!(<%= schema.singular %>)
    %<%= inspect schema.alias %>{}

  """
  def update_<%= schema.singular %>_failed!(<%= schema.singular %> = %<%= inspect schema.alias %>{}) do
    <%= schema.singular %>
    |> <%= inspect schema.alias %>.failed_changeset(%{})
    |> Repo.update!()
    |> <%= inspect pub_sub.alias %>.<%= pub_sub.broadcast %>(:updated)
  end

  @doc """
  Deletes every <%= schema.singular %> for a resource, with the option to delete only
  those matching specific links.

  ## Examples

    iex> delete_<%= schema.plural %>!(resource)
    %ResourceSchema{}

    iex> delete_<%= schema.plural %>!(resource, links: ["http://example.com/"])
    %ResourceSchema{}

  """
  def delete_<%= schema.plural %>!(resource = %_Schema{}, opts \\ []) do
    q = from l in <%= inspect schema.alias %>, where: [resource_id: ^resource.id]
    q = if links = opts[:links], do: where(q, [l], l.link in ^links), else: q
    Repo.delete_all(q)
    resource
  end
