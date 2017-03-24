defmodule Gradleize.Dependency.Gradle do
  @moduledoc """
  Gradle dependency handling.
  """

  alias Gradleize.Dependency

  @doc """
  Create a Gradle dependency in string notation "group:artifact:version".

  Return an IO list.
  """
  @spec create_dependency_string(Dependency.t) :: iolist
  def create_dependency_string(dep) do
    [dep.group_id, dep.artifact_id, dep.version]
    |> Enum.filter(& &1 != nil)
    |> Enum.intersperse(":")
  end

  @doc """
  Much like `create_dependency_string/1` but quoted.

  Use different quotes depending on the value of the version field.
  If its a variable `${var}` use double quotes, single quotes otherwise.

   Return an IO list.
  """
  @spec create_quoted_dependency_string(Dependency.t) :: iolist
  def create_quoted_dependency_string(dep) do
    quotes = if dep.version |> String.starts_with?("${"), do: ?", else: ?'
    [quotes, create_dependency_string(dep), quotes]
  end

  @doc """
  Create a Gradle configuration name like `compile` or `testCompile` for a dependency.

  Return either a configuration name or nil if the dependency cannot be transformed.

  See [Gradle DependencyHandler](https://docs.gradle.org/3.4.1/dsl/org.gradle.api.artifacts.dsl.DependencyHandler.html)
  for a definition of _configuration name_.
  """
  @spec create_configuration_name(Dependency.t) :: binary | nil
  def create_configuration_name(dep)
  def create_configuration_name(%Dependency{scope: nil}), do: "compile"
  def create_configuration_name(%Dependency{scope: "test"}), do: "testCompile"
  def create_configuration_name(%Dependency{scope: "provided"}), do: nil
  def create_configuration_name(%Dependency{scope: scope}), do: scope
end
