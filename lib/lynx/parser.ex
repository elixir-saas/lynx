defmodule Lynx.Parser do
  @default_strategies [:link]

  defmacro __using__(opts) do
    strategies = opts[:strategies] || []

    quote do
      def strategies(), do: unquote(strategies)
    end
  end

  def strategies() do
    Enum.map(@default_strategies, &strategy(&1))
  end

  def strategy(type), do: {type, pattern(type)}

  def pattern(:link) do
    ~r/(?<url>(?:https?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-_~%:\/?#[\]@!\$&'\(\)\*\+,;=]*[\w\-_\/?&\+])/u
  end

  def pattern(:mention), do: ~r{@\w+}u
  def pattern(:hashtag), do: ~r{#\w+}u
  def pattern(:cashtag), do: ~r{\$\w+}u
end
