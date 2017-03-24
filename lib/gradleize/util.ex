defmodule Gradleize.Util do
  @moduledoc """
  General purpose utilities.
  """

  @doc """
  Return a list of all subdirectories of `dir`.
  """
  def list_sub_directories(dir) do
    dir
    |> File.ls!
    |> Enum.map(fn f -> Path.join(dir, f) end)
    |> Enum.filter(&File.dir?/1)
  end

  @doc """
  Return a list of all subdirectories of `dir` that are considered to be a module root directory.
  A module root directory needs to have a `pom.xml`.
  Returns absolute paths, i.e. `dir` is included.
  """
  def list_module_directories(dir) do
    dir
    |> Gradleize.Util.list_sub_directories
    |> Enum.filter(fn module ->
         module
         |> Path.join("pom.xml")
         |> File.regular?
       end)
  end

  @doc """
  Return `nil` if the string parameter is empty, i.e. equal to "".
  """
  @spec empty_to_nil(binary) :: binary | nil
  def empty_to_nil(string)
  def empty_to_nil(""), do: nil
  def empty_to_nil(not_empty), do: not_empty

  @doc """
  Indent all lines of an IO list by 2 spaces.
  Each element of the given list is considered a line except for those that are just a newline.
  """
  def indent_iolist(iolist) do
    iolist
    |> Enum.map(&indent/1)
  end

  defp indent("\n"), do: "\n"
  defp indent(["\n"]), do: "\n"
  defp indent(line), do: ["  ", line]
end
