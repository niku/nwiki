defmodule Nwiki.CLI do
  def main(args) do
    {_, args, _} = OptionParser.parse(args, strict: [path: :string])

    case args do
      [input, output] ->
        Nwiki.run(input, output)

      _ ->
        show_help()
    end
  end

  def show_help() do
    IO.puts("""
    Usage: nwiki /path/to/input /path/to/output
    """)
  end
end
