defmodule Gradleize.Util do
  @moduledoc false

  @doc """
  Return a list of all subdirectories of `dir`.
  """
  def list_sub_directories(dir) do
    dir
    |> File.ls!
    |> Enum.map(fn f -> Path.join(dir, f) end)
    |> Enum.filter(&File.dir?/1)
  end

  @doc """
  Return a list of all subdirectories of `dir` that are considered to be a module root directory.
  A module root directory needs to have a `pom.xml`.
  Returns absolute paths, i.e. `dir` is included.
  """
  def list_module_directories(dir) do
    dir
    |> Gradleize.Util.list_sub_directories
    |> Enum.filter(fn module ->
         module
         |> Path.join("pom.xml")
         |> File.regular?
       end)
  end

  @project_home Application.get_env(:gradleize, :project_home)

  @doc """
  Get the main `pom.xml` of the configured project.
  """
  def main_pom do
    @project_home
    |> Path.join("pom.xml")
  end

  @doc """
  Get a module `pom.xml` of the configured project.
  """
  def module_pom(module) do
    @project_home
    |> Path.join("modules")
    |> Path.join(module)
    |> Path.join("pom.xml")
  end
end
