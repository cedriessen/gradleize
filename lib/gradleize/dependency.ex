defmodule Gradleize.Dependency do
  @moduledoc """
  Generic Java library dependency as defined by Maven and adopted by other build systems like Gradle.
  """

  import Gradleize.Util, only: [empty_to_nil: 1]

  defstruct group_id: nil, artifact_id: nil, version: nil, scope: nil, exclusions: []

  @type t :: %__MODULE__{
    group_id: binary,
    artifact_id: binary,
    version: nil | binary,
    scope: nil | binary,
    exclusions: list
  }

  def new do
    %__MODULE__{}
  end

  def group_id(dependency, group_id) do
    %{dependency | group_id: empty_to_nil(group_id)}
  end

  def artifact_id(dependency, artifact_id) do
    %{dependency | artifact_id: empty_to_nil(artifact_id)}
  end

  def version(dependency, version) do
    %{dependency | version: empty_to_nil(version)}
  end

  def scope(dependency, scope) do
    %{dependency | scope: empty_to_nil(scope)}
  end

  def exclusions(dependency, exclusions) do
    %{dependency | exclusions: exclusions}
  end
end
