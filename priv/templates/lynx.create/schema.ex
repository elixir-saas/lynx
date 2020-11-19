defmodule <%= inspect schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false<%= if schema.binary_id do %>
  @foreign_key_type :binary_id<% end %>

  schema <%= inspect schema.table %> do
    field :link, :string, primary_key: true
    field :resource_id, <%= if schema.binary_id, do: inspect(:binary_id), else: inspect(:integer) %>, primary_key: true

    field :page_title, :string
    field :page_description, :string
    field :page_site_name, :string
    field :page_url, :string
    field :page_icon_url, :string
    field :page_image_url, :string

    field :state, Ecto.Enum, values: [:loading, :failed, :done]
  end

  def changeset(<%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> cast(attrs, [:link, :resource_id])
    |> validate_required([:link, :resource_id])
    |> put_change(:state, :loading)
  end

  def loaded_changeset(<%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> cast(attrs, [:page_title, :page_description, :page_site_name, :page_page_url, :page_icon_url, :page_image_url])
    |> update_change(:page_description, &limit_string(&1, 255, ellipsis: true))
    |> put_change(:state, :done)
  end

  def failed_changeset(<%= schema.singular %>, _attrs) do
    change(<%= schema.singular %>, state: :failed)
  end

  defp limit_string(str, limit, opts) do
    if opts[:ellipsis] == true and String.length(str) > limit do
      String.slice(str, 0..(limit - 4)) <> "..."
    else
      String.slice(str, 0..(limit - 1))
    end
  end
end
