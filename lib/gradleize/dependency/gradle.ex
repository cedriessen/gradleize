defmodule Gradleize.Dependency.Gradle do
  @moduledoc """
  Gradle dependency handling.
  """

  alias Gradleize.Dependency

  @doc """
  Create a Gradle dependency "group:artifact:version" from a `$Gradleize.Dependency{}` struct.
  Return an io list.
  """
  def create_dependency(dep) do
    [dep.group_id, dep.artifact_id, dep.version]
    |> Enum.filter(& &1 != nil)
    |> Enum.intersperse(":")
  end

  @doc """
  Create the Gradle dependency command like `compile` or `test`.
  """
  def create_dependency_command(dep)
  def create_dependency_command(%Dependency{scope: nil}), do: "compile"
  def create_dependency_command(%Dependency{scope: scope}), do: scope
end
