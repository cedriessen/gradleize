defmodule Gradleize do
  @moduledoc """
  Main entry point.
  """

  alias Gradleize.Opencast

  @doc """
  See `Gradleize.ModuleBuildFile.generate_all/1`.

  Parameter `modules_home` defaults to the `modules/` directory of the configured Opencast project.
  """
  def generate_module_build_files do
    Gradleize.Generator.ModuleBuildFile.generate_all(Opencast.modules_home())
    Gradleize.Generator.DependenciesFile.generate(Opencast.dependencies_gradle(), Opencast.main_pom())
  end
end
