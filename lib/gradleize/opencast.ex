defmodule Gradleize.Opencast do
  @moduledoc """
  Opencast specifics like paths to modules etc.

  Set path the Opencast home directory in `config.exs`.
  """

  @project_home Application.get_env(:gradleize, :project_home)

  @doc """
  Get path of the main `pom.xml` of the configured Opencast project.
  """
  def main_pom do
    @project_home
    |> Path.join("pom.xml")
  end

  @doc """
  Get path to a module's `pom.xml` of the configured Opencast project.
  """
  def module_pom(module) do
    modules_home()
    |> Path.join(module)
    |> Path.join("pom.xml")
  end

  @doc """
  Get Opencast's home directory as configured in the config.
  """
  def project_home do
    @project_home
  end

  @doc """
  Home of all module directories of the configured Opencast project.
  """
  def modules_home do
    @project_home
    |> Path.join("modules")
  end
end
