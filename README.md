![Lynx Logo](./priv/static/images/logo-on-transparent.png)

# Lynx

Lynx is an Elixir library for extracting, analyzing, and formatting links.
It supports link detection from text and link unfurling, using the included OpenGraph client for scraping.
Generate migration, schema, and context files to easily add Lynx to your project.

## Installation

The package can be installed by adding `lynx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lynx, "~> 0.1.0"}
  ]
end
```

Read the docs at [https://hexdocs.pm/lynx](https://hexdocs.pm/lynx).

Once installed, run `lynx.create` to perform code generation for using `Lynx.LinkPreview` in your project.
