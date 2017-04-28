defmodule Gradleize do
  @moduledoc """
  Main entry point.
  """

  alias Gradleize.Opencast

  @doc """
  See `Gradleize.ModuleBuildFile.generate_all/1`.

  Parameter `modules_home` defaults to the `modules/` directory of the configured Opencast project.
  """
  def generate_module_build_files(modules_home \\ Opencast.modules_home()) do
    Gradleize.Generator.ModuleBuildFile.generate_all(modules_home)
  end
end
