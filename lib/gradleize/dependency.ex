defmodule Gradleize.Dependency do
  @moduledoc """
  Generic Java library dependency as defined by Maven and adopted by other build systems like Gradle.
  """

  import Gradleize.Util

  @enforce_keys [:group_id, :artifact_id]
  defstruct [:group_id, :artifact_id, :version, :scope]

  @doc """
  Take a dependency struct and set all of its fields that have an empty string value to `nil`.
  """
  def fix_empty(dependency) do
    %Gradleize.Dependency{
      group_id: empty_to_nil(dependency.group_id),
      artifact_id: empty_to_nil(dependency.artifact_id),
      version: empty_to_nil(dependency.version),
      scope: empty_to_nil(dependency.scope)
    }
  end
end
