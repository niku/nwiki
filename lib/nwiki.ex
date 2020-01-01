defmodule Nwiki do
  @moduledoc """
  Documentation for `Nwiki`.
  """

  @doc """
  Runs Nwiki
  """
  def run(input_path, output_path) when is_binary(input_path) and is_binary(output_path) do
    main_css_path = Path.join(["assets", "css", "main.css"])
    normalize_css_path = Path.join(["assets", "css", "normalize.css"])
    default_css_path = Path.join(["assets", "css", "default.css"])
    solarized_dark_css_path = Path.join(["assets", "css", "solarized-dark.css"])
    highlight_pack_js_path = Path.join(["assets", "js", "highlight.pack.js"])
    article_html_eex = Path.join(["templates", "article.html.eex"])
    index_html_eex = Path.join(["templates", "index.html.eex"])
    wiki_title = "nikulog"

    files =
      input_path
      |> Path.expand()
      |> Path.join("**")
      |> Path.wildcard()

    {markdowns, others} = Enum.split_with(files, &(Path.extname(&1) === ".md"))

    entries =
      markdowns
      |> Enum.map(fn path ->
        url =
          path
          |> Path.relative_to(Path.expand(input_path))
          |> Path.rootname()
          |> URI.parse()

        {:ok, ast} =
          path
          |> File.read!()
          |> parse()

        {url, ast}
      end)
      |> Enum.into(Map.new())

    all_links =
      entries
      |> Enum.map(fn {k, v} -> {k, collect_link(v)} end)
      |> Enum.into(Map.new())

    all_linked = collect_linked(all_links)

    entries
    |> Enum.each(fn {%URI{path: path} = url, ast} ->
      write_path = Path.join(output_path, path)

      write_path
      |> Path.dirname()
      |> File.mkdir_p!()

      body =
        ast
        |> add_extname_to_hashed_link_url(".html")
        |> Earmark.Transform.transform()

      links =
        all_links
        |> Map.get(url, Map.new())
        |> Map.keys()
        |> Enum.filter(fn
          %URI{host: nil} -> true
          _ -> false
        end)

      linked =
        all_linked
        |> Map.get(url, Map.new())
        |> Enum.map(fn u ->
          {u,
           all_links
           |> Map.get(u, Map.new())
           |> Map.keys()}
        end)
        |> Enum.into(Map.new())

      html =
        EEx.eval_file(article_html_eex,
          title: path,
          description: "",
          body: body,
          links: links,
          linked: linked,
          ga_tracking_id: nil
        )

      File.write!(write_path <> ".html", html)
    end)

    index_html =
      EEx.eval_file(index_html_eex,
        title: wiki_title,
        description: "",
        body: entries,
        ga_tracking_id: nil
      )

    File.write!(Path.join(output_path, "index.html"), index_html)

    others
    |> Enum.each(fn path ->
      write_path =
        path
        |> Path.relative_to(Path.expand(input_path))
        |> Path.rootname()

      write_path
      |> Path.dirname()
      |> File.mkdir_p!()

      File.cp!(path, Path.join(output_path, write_path))
    end)

    css_path = Path.join([output_path, "assets", "css"])
    File.mkdir_p!(css_path)
    File.cp!(main_css_path, Path.join(css_path, "main.css"))
    File.cp!(normalize_css_path, Path.join(css_path, "normalize.css"))
    File.cp!(default_css_path, Path.join(css_path, "default.css"))
    File.cp!(solarized_dark_css_path, Path.join(css_path, "solarized-dark.css"))

    js_path = Path.join([output_path, "assets", "js"])
    File.mkdir_p!(js_path)
    File.cp!(highlight_pack_js_path, Path.join(js_path, "highlight.pack.js"))
  end

  @doc """
  Parses markdown
  """
  def parse(markdown) when is_binary(markdown) do
    {:ok, ast, []} = Earmark.as_ast(markdown, pure_links: false)

    hashed_link_added_ast =
      ast
      |> EarmarkHashedLink.add_hashed_link()
      |> EarmarkRawHtml.melt_raw_html_into_ast()

    {:ok, hashed_link_added_ast}
  end

  @doc """
  Collects urls which have link as same as the url
  """
  def collect_linked(all_links) when is_map(all_links) do
    all_links
    |> Enum.flat_map(fn {url, links} ->
      Enum.map(links, fn {link_url, _link_text} ->
        {link_url, url}
      end)
    end)
    |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)
    |> Enum.map(fn {k, v} -> {k, MapSet.new(v)} end)
    |> Enum.into(Map.new())
  end

  @doc """
  Collects ASTs which is represented as link (i.e. <a href="..."></a> tags) from AST
  """
  def collect_link(ast) when is_list(ast) do
    do_collect_link(ast, Map.new())
  end

  @doc false
  def do_collect_link(ast, links)

  def do_collect_link([], links), do: links

  def do_collect_link([{tag, attr, ast} | rest], links) when tag in ["a", "A"] do
    url =
      Enum.find_value(attr, fn
        {"href", value} ->
          value

        _ ->
          nil
      end)

    text =
      case ast do
        [x] when is_binary(x) -> x
        # We handle only a text. Other are just ignore right now.
        _ -> nil
      end

    with u when not is_nil(url) <- url,
         t when not is_nil(text) <- text do
      do_collect_link(
        rest,
        Map.update(links, URI.parse(u), MapSet.new([t]), &MapSet.put(&1, t))
      )
    else
      _ ->
        do_collect_link(rest, links)
    end
  end

  def do_collect_link([{_tag, _attr, ast} | rest], links) do
    do_collect_link(rest, do_collect_link(ast, links))
  end

  def do_collect_link([string | rest], links) when is_binary(string) do
    do_collect_link(rest, links)
  end

  def add_extname_to_hashed_link_url(ast, extname) when is_list(ast) and is_binary(extname) do
    do_add_extname_to_hashed_link_url(ast, extname, [])
  end

  @doc false
  def do_add_extname_to_hashed_link_url(ast, extname, new_ast)

  def do_add_extname_to_hashed_link_url([], _extname, new_ast), do: Enum.reverse(new_ast)

  def do_add_extname_to_hashed_link_url([{tag, attr, ast} | rest], extname, new_ast)
      when tag in ["a", "A"] do
    text =
      case ast do
        [x] when is_binary(x) -> x
        # We handle only a text. Other are just ignore right now.
        _ -> nil
      end

    new_attr =
      attr
      |> Enum.map(fn
        {"href", value} when is_binary(text) and "#" <> value == text ->
          {"href", value <> extname}

        x ->
          x
      end)

    do_add_extname_to_hashed_link_url(rest, extname, [
      {tag, new_attr, do_add_extname_to_hashed_link_url(ast, extname, [])} | new_ast
    ])
  end

  def do_add_extname_to_hashed_link_url([{tag, attr, ast} | rest], extname, new_ast) do
    do_add_extname_to_hashed_link_url(rest, extname, [
      {tag, attr, do_add_extname_to_hashed_link_url(ast, extname, [])} | new_ast
    ])
  end

  def do_add_extname_to_hashed_link_url([string | rest], extname, new_ast)
      when is_binary(string) do
    do_add_extname_to_hashed_link_url(rest, extname, [string | new_ast])
  end
end
