defmodule Gradleize do
  @moduledoc """
  Main entry point.
  """

  alias Gradleize.Opencast

  @doc """
  See `Gradleize.ModuleBuildFile.create_module_build_files/1`.

  Parameter `modules_home` defaults to the `modules/` directory of the configured Opencast project.
  """
  def create_module_build_files(modules_home \\ Opencast.modules_home()) do
    Gradleize.ModuleBuildFile.create_module_build_files(modules_home)
  end
end
