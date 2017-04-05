defmodule Gradleize.StaticWeave do
  @moduledoc """
  Detect modules that need JPA static weaving.

  Detection is based on the existence of the `staticweave-maven-plugin` in the module's pom.

      <build>
        <plugins>
          <plugin>
            <groupId>de.empulse.eclipselink</groupId>
            <artifactId>staticweave-maven-plugin</artifactId>
          </plugin>
        </plugins>
      </build>
  """

  alias Gradleize.Opencast
  alias Gradleize.Util
  alias Gradleize.Dependency.Maven

  import SweetXml

  @doc """
  Find all modules that need static weaving.

  Return a list of module names, e.g. `["matterhorn-asset-manager-impl", "matterhorn-authorization-manager"]`.
  """
  def find_modules_to_weave(modules_home \\ Opencast.modules_home()) do
    modules_home
    |> Util.list_module_directories
    |> Enum.filter(&needs_weaving?/1)
    |> Enum.map(&Path.basename/1)
  end

  def needs_weaving?(module_dir) do
    module_dir
    |> Opencast.module_pom
    |> Maven.parse_pom
    |> xpath(~x"//build/plugins/plugin/artifactId/text()"sl)
    |> Enum.map(&String.trim/1)
    |> Enum.member?("staticweave-maven-plugin")
  end
end
