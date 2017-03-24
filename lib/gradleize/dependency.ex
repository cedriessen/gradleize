defmodule Gradleize.Dependency do
  @moduledoc """
  Generic Java library dependency as defined by Maven and adopted by other build systems like Gradle.
  """

  @enforce_keys [:group_id, :artifact_id]
  defstruct [:group_id, :artifact_id, :version, :scope]

  @doc """
  Check if `field` is defined.
  A field is considered to be defined if it is neither `nil` nor an empty string.
  """
  def defined?(dependency, field) do
    not(defined?(dependency, field))
  end

  @doc """
  Check if `field` is undefined.
  A field is considered to be defined if it is neither `nil` nor an empty string.
  """
  def undefined?(dependency, field) do
    Map.get(dependency, field) in ["", nil]
  end
end
