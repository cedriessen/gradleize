defmodule Gradleize.Dependency do
  @moduledoc """
  Generic Java library dependency as defined by Maven and adopted by other build systems like Gradle.
  """

  @enforce_keys [:group_id, :artifact_id]
  defstruct [:group_id, :artifact_id, :version, :scope]

  def defined?(dependency, field) do
    not(defined?(dependency, field))
  end

  def undefined?(dependency, field) do
    Map.get(dependency, field) in ["", nil]
  end
end
