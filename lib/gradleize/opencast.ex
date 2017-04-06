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

  def feature_xml do
    @project_home
    |> Path.join("assemblies/karaf-features/src/main/feature/feature.xml")
  end

  @doc """
  Get path to a module's `pom.xml` of the configured Opencast project.

  Pass only the module name like `matterhorn-common` or an absolute path
  like `/Users/ced/dev/mh/opencast/modules/matterhorn-common`.
  """
  def module_pom(module) do
    module
    |> module_home
    |> Path.join("pom.xml")
  end

  @doc """
  Get path to a module's `bnd.bnd` of the configured Opencast project.

  Pass only the module name like `matterhorn-common` or an absolute path
  like `/Users/ced/dev/mh/opencast/modules/matterhorn-common`.
  """
  def module_bnd(module) do
    module
    |> module_home
    |> Path.join("bnd.bnd")
  end

  @doc """
  Get path to a module's gradle file of the configured Opencast project.
  Gradle files are named after the module, e.g. `matterhorn-common.gradle`.

  Pass only the module name like `matterhorn-common` or an absolute path
  like `/Users/ced/dev/mh/opencast/modules/matterhorn-common`.
  """
  def module_gradle(module) do
    module_home = module_home(module)
    module_name = Path.basename(module_home)
    module_home
    |> Path.join("#{module_name}.gradle")
  end

  @doc """
  Get a module's home directory.

  ## Params
  - `module` - either just the module name or an absolute path
  """
  def module_home(module) do
    case Path.type(module) do
      :relative ->
        modules_home()
        |> Path.join(module)
      :absolute ->
        module
    end
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
