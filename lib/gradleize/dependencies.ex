defmodule Gradleize.Dependencies do
  @moduledoc """
  Transforming Maven dependency declarations to Gradle.
  """

  alias Gradleize.Dependency.Maven
  alias Gradleize.Dependency.Gradle
  alias Gradleize.Dependency

  @doc """
  Create a list of library definitions from the `<dependencyManagement>` section of a Maven pom.

  ## Params
  - `pom` - path to `pom.xml`

  ## Return
  A set of libary definitions like this
  ```
  libraries.activation = 'javax.activation:activation:1.1.1'
  libraries.activemq_all = 'org.apache.activemq:activemq-all:5.3.1'
  libraries.aws_java_sdk_osgi = "com.amazonaws:aws-java-sdk-osgi:${versions.aws}"
  libraries.c3p0 = 'com.mchange:c3p0:0.9.5.2'
  ```
  """
  def create_library_definitions(pom) do
    pom
    |> Maven.parse_dependencies(section: :management)
    |> Stream.map(&create_library_definition/1)
    |> Enum.sort
    |> Enum.intersperse("\n")
  end

  @doc """
  Create Gradle dependency declarations from a modules's pom.

  Managed dependencies -- those that do not have a version -- are added referring to a
  defined library. See `create_library_definitions/1`.

  ## Params
  - `pom` - path to `pom.xml`

  ## Return
  Dependency declarations like this
  ```
  compile 'org.freemarker:freemarker:2.3.15'
  compile 'org.hamcrest:hamcrest-core:1.3'
  compile 'org.hamcrest:hamcrest-library:1.3'
  compile 'pl.pragmatists:JUnitParams:1.0.4'
  compile libraries.c3p0
  compile libraries.com_springsource_org_apache_commons_beanutils
  compile libraries.commons_codec
  compile libraries.commons_collections
  testCompile 'org.apache.servicemix.specs:org.apache.servicemix.specs.jaxp-api-1.4:2.4.0'
  testCompile 'xmlunit:xmlunit:1.5'
  testCompile libraries.easymock
  ```
  """
  @spec create_module_dependencies(binary) :: iolist
  def create_module_dependencies(pom) do
    pom
    |> Maven.parse_dependencies(section: :dependencies)
    |> Stream.flat_map(&create_dependency_declaration/1)
    |> Enum.sort
    |> Enum.intersperse("\n")
  end

  # Create a Gradle dependency declaration.
  # Return a single elemented list in case the given dependency can be transformed, or [] if not.
  defp create_dependency_declaration(dep) do
    case Gradle.create_configuration_name(dep) do
      nil ->
        []
      configurationName ->
        dependency =
          dep
          |> rewrite_version
          |> create_dependency_string_for_declaration
        case create_exclusions(dep) do
          [] ->
            [[configurationName, " ", dependency]]
          exclusions ->
            [[configurationName, ?(, dependency, ") {\n", exclusions, "\n}"]]
        end
    end
  end

  # Helper function for `create_dependency_declaration/1`
  #
  defp create_dependency_string_for_declaration(%Dependency{version: nil, artifact_id: artifact_id}) do
    create_lib_ref(artifact: artifact_id)
  end
  # match on the rewritten dependency version
  defp create_dependency_string_for_declaration(%Dependency{version: "${versions.project}", artifact_id: artifact_id}) do
    ["project(':", artifact_id, "')"]
  end
  defp create_dependency_string_for_declaration(dep) do
    Gradle.create_quoted_dependency_string(dep)
  end

  defp create_exclusions(%Dependency{exclusions: []}), do: []
  defp create_exclusions(%Dependency{exclusions: exclusions}) do
    exclusions
    |> Stream.map(&Gradle.create_exclusion/1)
    |> Enum.intersperse("\n")
  end

  # Create a Gradle library definition from a parsed Maven dependency.
  defp create_library_definition(dep) do
    lib_ref = create_lib_ref(artifact: dep.artifact_id)
    dependency =
      dep
      |> rewrite_version
      |> Gradle.create_quoted_dependency_string
    [lib_ref, " = ", dependency]
  end

  # Rewrite the version field of a dependency struct.
  defp rewrite_version(dep) do
    %{dep | version: rewrite_version_var(dep.version)}
  end

  # Rewrite a Maven version variable ${xyz.version} to Gradle ${versions.xyz}
  # A plain version is passed through.
  defp rewrite_version_var(nil), do: nil
  defp rewrite_version_var(version) do
    case Regex.run(~r/\$\{(.*?).version\}/, version, capture: :all_but_first) do
      [version] ->
        "${versions.#{underscore(version)}}"
      nil ->
        version
    end
  end

  # Create a Gradle library reference for a lib.
  defp create_lib_ref(lib: lib_name), do: ["libraries.", lib_name]
  defp create_lib_ref(artifact: artifact_id) do
    lib_name = create_lib_name(artifact_id)
    create_lib_ref(lib: lib_name)
  end

  # Create a Gradle lib name from an artifact id.
  defp create_lib_name("org.springframework." <> rest), do: create_lib_name("spring", rest)
  defp create_lib_name("org.eclipse." <> rest), do: create_lib_name("eclipse", rest)
  defp create_lib_name("org.apache.servicemix.bundles." <> rest), do: underscore(rest)
  defp create_lib_name("org.apache.felix." <> rest), do: create_lib_name("felix", rest)
  defp create_lib_name("slf4j-api"), do: "slf4j"
  defp create_lib_name("httpclient-osgi"), do: "httpclient"
  defp create_lib_name("httpcore-osgi"), do: "httpcore"
  defp create_lib_name(rest), do: underscore(rest)

  defp create_lib_name(prefix, suffix) do
    "#{prefix}_#{underscore(suffix)}"
  end

  # turn a set of characters into underscores
  defp underscore(word), do: word |> String.replace(~r/[.-]/, "_")
end
