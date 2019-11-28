defmodule NwikiTest do
  use ExUnit.Case
  doctest Nwiki

  test "add extname to hashed link url" do
    ast = [
      {"p", [], ["The quick brown ", {"a", [{"href", "fox"}], ["#fox"]}]},
      {"ul", [],
       [
         {"li", [],
          [
            {"p", [], ["jumps over the lazy"]},
            {"ul", [], [{"li", [], [{"a", [{"href", "dog"}], ["#dog"]}]}]}
          ]}
       ]}
    ]

    expected = [
      {"p", [], ["The quick brown ", {"a", [{"href", "fox.html"}], ["#fox"]}]},
      {"ul", [],
       [
         {"li", [],
          [
            {"p", [], ["jumps over the lazy"]},
            {"ul", [], [{"li", [], [{"a", [{"href", "dog.html"}], ["#dog"]}]}]}
          ]}
       ]}
    ]

    Nwiki.add_extname_to_hashed_link_url(ast, ".html")
  end

  test "parse markdown" do
    markdown = """
    The quick brown #fox jumps over the lazy #dog .

    - a
    - b
    - c
    """

    ast = [
      {
        "p",
        [],
        [
          "The quick brown ",
          {"a", [{"href", "fox"}], ["#fox"]},
          " jumps over the lazy ",
          {"a", [{"href", "dog"}], ["#dog"]},
          " ."
        ]
      },
      {
        "ul",
        [],
        [
          {"li", [], ["a"]},
          {"li", [], ["b"]},
          {"li", [], ["c"]}
        ]
      }
    ]

    assert {:ok, ast} == Nwiki.parse(markdown)
  end

  test "collect links from ast" do
    ast = [
      {
        "p",
        [],
        [
          "The quick brown ",
          {"a", [{"href", "fox"}], ["#fox"]},
          " jumps over the lazy ",
          {"a", [{"href", "dog"}], ["#dog"]},
          " ."
        ]
      },
      {
        "ul",
        [],
        [
          {"li", [], ["a"]},
          {"li", [], ["b"]},
          {"li", [], ["c"]}
        ]
      }
    ]

    expected = %{
      %URI{path: "dog"} => MapSet.new(["#dog"]),
      %URI{path: "fox"} => MapSet.new(["#fox"])
    }

    assert expected == Nwiki.collect_link(ast)
  end

  test "collect url the article is linked" do
    expected = %{
      %URI{path: "a"} => MapSet.new([%URI{path: "x"}]),
      %URI{path: "b"} =>
        MapSet.new([
          %URI{path: "x"},
          %URI{path: "y"},
          %URI{path: "z"}
        ])
    }

    all_links = %{
      %URI{path: "x"} => %{
        %URI{path: "a"} => MapSet.new(["#a"]),
        %URI{path: "b"} => MapSet.new(["#b"])
      },
      %URI{path: "y"} => %{
        %URI{path: "b"} => MapSet.new(["#b"])
      },
      %URI{path: "z"} => %{
        %URI{path: "b"} => MapSet.new(["#b"])
      }
    }

    assert expected == Nwiki.collect_linked(all_links)
  end
end
