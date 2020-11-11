defmodule LynxTest do
  use ExUnit.Case

  doctest Lynx.Text

  describe "linkify_text" do
    test "inserts a link into a binary" do
      assert Lynx.HTML.linkify_text("go to www.example.com!") == [
        "go to ",
        {:safe, [?<, "a", [[?\s, "href", ?=, ?", "http://www.example.com", ?"]], ?>, "www.example.com", ?<, ?/, "a", ?>]},
        "!"
      ]
    end

    test "inserts multiple links into a binary" do
      assert Lynx.HTML.linkify_text("go to www.example.com and test.com/some/path") == [
        "go to ",
        {:safe, [?<, "a", [[?\s, "href", ?=, ?", "http://www.example.com", ?"]], ?>, "www.example.com", ?<, ?/, "a", ?>]},
        " and ",
        {:safe, [?<, "a", [[?\s, "href", ?=, ?", "http://test.com/some/path", ?"]], ?>, "test.com/some/path", ?<, ?/, "a", ?>]}
      ]
    end

    test "adds link attributes" do
      assert Lynx.HTML.linkify_text("www.example.com", link_attrs: [target: "_blank", rel: "noopener noreferrer"]) == [
        {:safe, [?<, "a", [
          [?\s, "href", ?=, ?", "http://www.example.com", ?"],
          [?\s, "rel", ?=, ?", "noopener noreferrer", ?"],
          [?\s, "target", ?=, ?", "_blank", ?"]
        ], ?>, "www.example.com", ?<, ?/, "a", ?>]}
      ]
    end

    test "processes the link href" do
      assert Lynx.HTML.linkify_text("www.example.com", process_href: & "#{&1}#anchor")
        == [{:safe, [?<, "a", [[?\s, "href", ?=, ?", "http://www.example.com#anchor", ?"]], ?>, "www.example.com", ?<, ?/, "a", ?>]}]
    end

    test "processes the link text" do
      assert Lynx.HTML.linkify_text("www.example.com", process_text: & "(#{&1})")
        == [{:safe, [?<, "a", [[?\s, "href", ?=, ?", "http://www.example.com", ?"]], ?>, "(www.example.com)", ?<, ?/, "a", ?>]}]
    end
  end
end
