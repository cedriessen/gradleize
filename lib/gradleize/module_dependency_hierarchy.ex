defmodule Gradleize.ModuleDependencyHierarchy do
  @moduledoc false

  alias Gradleize.ModuleDependencyHierarchy.Parser

  def build_hierarchy(dependencies) do
    # {module, resolved, unresolved}
    modules =
      dependencies
      |> Parser.parse
      |> Enum.map(fn {module, dependencies} -> {module, [], dependencies} end)
    case resolve([], modules, [], length(modules)) do
      {:ok, resolved} ->
        print_modules(resolved)
      {:error, resolved, unresolved} ->
        print_modules(resolved)
        print_modules(unresolved)
    end
  end

  defp print_modules(modules) do
    modules
    |> Enum.each(&print_module/1)
  end

  defp print_module({module, [], []}), do: IO.puts(module)
  defp print_module({module, resolved, unresolved}) do
    IO.puts(module)
    resolved
    |> Enum.each(& IO.puts(" + " <> &1))
    unresolved
    |> Enum.each(& IO.puts(" - " <> &1))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # resolved, unresolved, take_over, modules_count
  def resolve(m_resolved, [], [], _) do
    {:ok, m_resolved |> Enum.reverse}
  end
  def resolve(
    m_resolved,
    [{_, _, []} = m | m_rest], # no more unresolved dependencies
    take_over,
    count)
  do
    resolve([m | m_resolved], m_rest, take_over, count)
  end
  def resolve(
    m_resolved,
    [{m_name, d_resolved, [d | d_rest]} = m | m_rest],
    take_over,
    count)
  do
    if contains?(m_resolved, d) do
      resolve(
        m_resolved,
        [{m_name, [d | d_resolved], d_rest} | m_rest], # move dependency to resolved and try on
        take_over,
        count)
    else
      resolve(
        m_resolved,
        m_rest,
        [m | take_over], # move module to take_over for a later try
        count)
    end
  end
  def resolve(resolved, [], take_over, c) when length(take_over) < c do
    resolve(resolved, take_over, [], length(take_over))
  end
  def resolve(resolved, [], take_over, _) do
    {:error, resolved |> Enum.reverse, take_over}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # check if dependency (module name) is contained in the list of module tuples
  defp contains?(modules, dependency) do
    modules
    |> Enum.any?(fn {m, _, _} -> m == dependency end)
  end
end
