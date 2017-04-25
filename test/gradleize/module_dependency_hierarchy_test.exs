defmodule Gradleize.ModuleDependencyHierarchyTest do
  use ExUnit.Case

  alias Gradleize.ModuleDependencyHierarchy, as: Hierarchy

  # not a test but a runner
  test "build hierarchy" do
    "lib/module_dependencies.txt"
    |> File.read!
    |> Gradleize.ModuleDependencyHierarchy.build_hierarchy
    |> Gradleize.ModuleDependencyHierarchy.show_hierarchy
  end
end
