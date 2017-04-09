defmodule Gradleize.ModuleDependencyHierarchy.Parser do
  @moduledoc false

  use Combine, parsers: [:text]

  @word_chars ~r/[\-\w]+/

  @doc """
  Parse a dependencies string of format
  `[[module, [depends_on_module, ...]], [module, [depends_on_module, ...]], ...]`
  """
  def parse(str) do
    str
    |> Combine.parse(module_list())
    |> case do # unwrap list
         [] -> []
         [x] -> x
       end
  end

  def module_list do
    ignore(token("["))
    |> sep_by(module(), token(","))
    |> ignore(token("]"))
  end

  def module do
    [
      ignore(token("[")),
      word_of(@word_chars),
      ignore(token(",")),
      ignore(token("[")),
      sep_by(word_of(@word_chars), token(char(","))),
      ignore(token("]")),
      ignore(token("]")),
    ]
    |> pipe(&List.to_tuple/1)
  end

  def token(str) when is_binary(str) do
    token(string(str))
  end
  def token(parser) do
    [
      ignore(many(space())),
      parser,
      ignore(many(space()))
    ]
    |> compose
  end

  @doc """
  Compose a list of parsers into a single one.
  """
  def compose(parsers) do
    pipe(parsers, fn x -> x end)
  end
end
