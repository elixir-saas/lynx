defmodule Mix.Tasks.Lynx.Create do
  use Mix.Task
  alias Mix.Tasks.Phx
  alias Mix.Phoenix.{Context, Schema}

  @shortdoc "Creates the infrastructure for using Lynx.LinkPreview"

  @moduledoc """
  Creates the infrastructure for using Lynx.LinkPreview

  """

  @switches [
    table: :string,
    schema_name: :string,
    pub_sub: :string,
    binary_id: :boolean
  ]

  @impl true
  def run(args) do
    case OptionParser.parse!(args, switches: @switches, aliases: []) do
      {opts, [context_name]} ->
        {schema, schema_module} = build_schema(context_name, opts)
        context = build_context(context_name, schema, opts)
        pub_sub = build_pub_sub(schema, opts)

        context
        |> copy_new_files(schema_module, context: context, schema: schema, pub_sub: pub_sub)
        |> Phx.Gen.Context.print_shell_instructions()

      {_, _} ->
        Mix.raise(
          "expected lynx.create to receive the context name" <>
            "got: #{inspect(Enum.join(args, " "))}"
        )
    end
  end

  def generator_paths(), do: [".", :lynx]

  def build_schema(context_name, opts) do
    schema_name = Keyword.get(opts, :schema_name, "LinkPreview")
    table = Keyword.get(opts, :table, "link_previews")

    schema_module = inspect(Module.concat(context_name, schema_name))

    {Schema.new(schema_module, table, [], opts), schema_module}
  end

  def build_context(context_name, schema, opts) do
    Context.new(context_name, schema, opts)
  end

  def build_pub_sub(schema, opts) do
    ctx_app = opts[:context_app] || Mix.Phoenix.context_app()
    ctx_pub_sub = opts[:pub_sub] || Module.concat([Mix.Phoenix.context_base(ctx_app), PubSub])

    Map.new()
    |> Map.put(:module, Module.concat([schema.module, PubSub]))
    |> Map.put(:alias, Module.concat([schema.alias, PubSub]))
    |> Map.put(:subscribe, "subscribe_#{schema.singular}")
    |> Map.put(:broadcast, "broadcast_#{schema.singular}")
    |> Map.put(:ctx_pub_sub, ctx_pub_sub)
  end

  def copy_new_files(%Context{schema: schema} = context, schema_module, binding) do
    if schema.generate?, do: schema_copy_new_files(schema, binding)
    pub_sub_copy_new_files(schema, schema_module, binding)
    inject_schema_access(context, binding)

    context
  end

  defp schema_copy_new_files(%Schema{context_app: ctx_app} = schema, binding) do
    Mix.Phoenix.copy_from(generator_paths(), "priv/templates/lynx.create", binding, [
      {:eex, "schema.ex", schema.file}
    ])

    if schema.migration? do
      migration_path =
        Mix.Phoenix.context_app_path(
          ctx_app,
          "priv/repo/migrations/#{timestamp()}_create_#{schema.table}.exs"
        )

      Mix.Phoenix.copy_from(generator_paths(), "priv/templates/lynx.create", binding, [
        {:eex, "migration.exs", migration_path}
      ])
    end
  end

  defp pub_sub_copy_new_files(%Schema{context_app: ctx_app}, schema_module, binding) do
    file =
      Mix.Phoenix.context_lib_path(
        ctx_app,
        Phoenix.Naming.underscore(schema_module) <> "_pub_sub.ex"
      )

    Mix.Phoenix.copy_from(generator_paths(), "priv/templates/lynx.create", binding, [
      {:eex, "pub_sub.ex", file}
    ])
  end

  defp inject_schema_access(%Context{file: file} = context, binding) do
    unless Context.pre_existing?(context) do
      template =
        Mix.Phoenix.eval_from(
          Mix.Phoenix.generator_paths(),
          "priv/templates/phx.gen.context/context.ex",
          binding
        )

      Mix.Generator.create_file(file, template)
    end

    generator_paths()
    |> Mix.Phoenix.eval_from("priv/templates/lynx.create/schema_access.ex", binding)
    |> inject_eex_before_final_end(file, binding)
  end

  defp inject_eex_before_final_end(content_to_inject, file_path, binding) do
    file = File.read!(file_path)

    if String.contains?(file, content_to_inject) do
      :ok
    else
      Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path)])

      file
      |> String.trim_trailing()
      |> String.trim_trailing("end")
      |> EEx.eval_string(binding)
      |> Kernel.<>(content_to_inject)
      |> Kernel.<>("end\n")
      |> write_file(file_path)
    end
  end

  defp write_file(content, file) do
    File.write!(file, content)
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
