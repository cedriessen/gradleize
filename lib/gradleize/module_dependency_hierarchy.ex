defmodule Gradleize.ModuleDependencyHierarchy do
  @moduledoc """
  Create a project modules dependency hierarchy.
  """

  alias Gradleize.ModuleDependencyHierarchy.Parser
  alias Gradleize.Shell

  @type module_name :: binary
  @type mod :: {module_name, resolved_dependencies :: [module_name], unresolved_dependencies :: [module_name]}

  def build_hierarchy(dependencies) do
    # [{module, resolved, unresolved}]
    modules =
      dependencies
      |> Parser.parse
      |> Enum.map(fn {module, dependencies} ->
           filtered =
             dependencies
             |> Enum.filter(& &1 != "android-mms")
           {module, [], filtered}
         end)

    # start resolution
    {resolved, unresolved} = resolve([], modules, [], length(modules))
    print_modules(resolved, [?\n, :green_background, :black, "FULLY RESOLVED"])
    print_modules(unresolved, [?\n, :red_background, :black, "UNRESOLVED"])
  end

  defp print_modules([], header) do
  end
  defp print_modules(modules, header) do
    Shell.ansi header
    modules
    |> Enum.each(&print_module/1)
  end

  @spec print_module(mod) :: any
  defp print_module({module, [], []}), do: Shell.text(module)
  defp print_module({module, resolved, unresolved}) do
    Shell.text [?\n, module]
    resolved
    |> Enum.sort
    |> Enum.each(& Shell.ansi [:green, " + ", &1])
    unresolved
    |> Enum.sort
    |> Enum.each(& Shell.ansi [:red, " - ", &1])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Resolve module dependendies and return a sorted list which shows the dependency hierarchy
  of the modules.

  ## Params
  - `resolved`     - list of modules whose dependencies have been fully resolved
  - `unresolved`   - list of modules with unresolved dependencies
  - `again`        - list of modules which cannot be resolved in the current resolution iteration.
                     Try to resolve those in the next round.
  - `count`        - number of unresolved modules the current resolution iteration has been started with

  Return a tuple of module lists `{fully_resolved, unresolved}`.
  """
  @spec resolve([mod], [mod], [mod], integer) :: {[mod], [mod]}
  def resolve(resolved, unresolved, again, count)
  # match module in unresolved with no more unresolved dependencies
  def resolve(mrs, [{_, _, []} = mu | mus], mas, c) do
    resolve([mu | mrs], mus, mas, c)
  end
  # inspect first unresolved dependency
  def resolve(mrs, [{mn, drs, [du | dus]} | mus], mas, c) do
    if mrs |> contains?(du) do
      # the list of resolved modules contains the unresolved dependency
      # -> move dependency to resolved and try next unresolved dependency
      resolve(mrs, [{mn, [du | drs], dus} | mus], mas, c)
    else
      # Move module to 'again' list for a later try.
      # In order to try to resolve as much as possible move the unresolved dependency to the end
      # of dependency list.
      resolve(mrs, mus, [{mn, drs, dus ++ [du]} | mas], c)
    end
  end
  # end of iteration, still some module to try again, so start a new iteration
  def resolve(mrs, [], mas, c) when length(mas) < c do
    resolve(mrs, mas, [], length(mas))
  end
  # End of iteration/resolution process.
  # Either resolution has been fully done
  # _or_
  # some dependencies cannot be resolved. This is because the amount of unresolved modules
  # has not been reduced since the last iteration. See function head above.
  def resolve(mrs, [], mas, _) do
    {mrs |> Enum.reverse, mas}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # check if dependency (module name) is contained in the list of module tuples
  @spec contains?([mod], module_name) :: boolean
  defp contains?(modules, dependency) do
    modules
    |> Enum.any?(fn {mn, _, _} -> mn == dependency end)
  end
end
