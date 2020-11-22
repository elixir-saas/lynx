defmodule LynxTest.ParserWithMentions do
  use Lynx.Parser,
    strategies: [
      Lynx.Parser.strategy(:link),
      Lynx.Parser.strategy(:mention)
    ]
end
