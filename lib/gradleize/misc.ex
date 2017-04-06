defmodule Gradleize.Misc do
  @moduledoc """
  Miscellanous transformations.
  """

  alias Gradleize.Opencast
  alias Gradleize.Shell

  @doc """
  Create module include statements for `settings.gradle`.

  ## Param
  - `module_home` - home directory of all project module directories
  """
  def create_module_includes(module_home) do
    module_home
    |> Gradleize.Util.list_module_directories
    |> Enum.map(fn module_dir ->
         module_name = Path.basename(module_dir)
         "include ':#{module_name}'"
       end)
    |> Enum.each(&IO.puts/1)
  end

  @doc """
  Print `bnd.bnd` and Gradle build file of a module to the console.

  ## Param
  - `module` - either the module name which is then resolved against the configured Opencast home
               or a path to a module.
  """
  def show_bnd_and_gradle(module) do
    Shell.info "GRADLE"
    module
    |> Opencast.module_gradle
    |> File.read!
    |> IO.puts

    Shell.info "\nBND"
    module
    |> Opencast.module_bnd
    |> File.read!
    |> IO.puts
  end

  @doc """
  Uncomment a module in Opencast's feature XML. Give just the module name, e.g. `matterhorn-common`.
  The `feature.xml` will be modified in-place.
  """
  def uncomment_module_in_feature_xml(module) do
    # read and transform
    feature_xml =
      Opencast.feature_xml
      |> File.read!
      |> String.split("\n")
      |> Stream.map(fn line ->
           case Regex.run(~r/^\s*<!--(.*?<bundle.*?#{module}.*?)-->\s*$/, line, capture: :all_but_first) do
             nil -> line
             [bundle] -> bundle
           end
         end)
      |> Enum.join("\n")
    # no write back
    Opencast.feature_xml
    |> File.write!(feature_xml)
  end
end
