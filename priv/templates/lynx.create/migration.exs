defmodule <%= inspect schema.repo %>.Migrations.Create<%= Macro.camelize(schema.table) %> do
  use <%= inspect schema.migration_module %>

  def change() do
    create table(:<%= schema.table %>, primary_key: false) do
      add :link, :string, null: false, primary_key: true
      add :resource_id, :binary_id, null: false, primary_key: true

      add :page_title, :string
      add :page_description, :string
      add :page_site_name, :string
      add :page_url, :string
      add :page_icon_url, :string
      add :page_image_url, :string

      add :state, :string, null: false
    end

    create index(:<%= schema.table %>, [:link])
    create index(:<%= schema.table %>, [:resource_id])
  end
end
