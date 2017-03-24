defmodule Gradleize.Dependencies do
  @moduledoc """
  Transforming Maven dependency declarations to Gradle.
  """

  alias Gradleize.Dependency.Maven
  alias Gradleize.Dependency.Gradle

  @doc """
  Create a list of library definitions from the `<dependencyManagement>` section of a Maven pom.

  Params
  - `pom` - pom file path
  """
  def create_library_definitions(pom) do
    pom
    |> Maven.parse_dependencies(section: :management)
    |> Stream.map(&create_library_definition/1)
    |> Enum.sort
    |> Enum.intersperse("\n")
    |> IO.puts
  end

  @doc """
  Create Gradle dependency definitions from a modules's pom.

  Params
  - `pom` - pom file path
  """
  def create_module_dependencies(pom) do
    pom
    |> Maven.parse_dependencies(section: :dependencies)
    |> Stream.flat_map(&create_dependency_declaration/1)
    |> Enum.sort
    |> Enum.intersperse("\n")
    |> IO.puts
  end

  # Create a Gradle dependency declaration.
  # Return a single elemented list in case the given dependency can be transformed, or [] if not
  defp create_dependency_declaration(dep) do
    case Gradle.create_configuration_name(dep) do
      nil ->
        []
      configurationName ->
        dependency =
          case dep.version do
            nil -> create_lib_name(dep.artifact_id)
            _ -> Gradle.create_dependency_string(dep)
          end
        [[configurationName, " ", dependency]]
    end
  end

  # Create a Gradle library definition from a parsed Maven dependency.
  defp create_library_definition(dep) do
    lib_ref = create_lib_ref_from_artifact_id(dep.artifact_id)
    dependency =
      dep
      |> rewrite_version
      |> Gradle.create_dependency_string
    quotes = if dep.version |> String.starts_with?("${"), do: '"', else: "'"
    [lib_ref, " = ", quotes, dependency, quotes]
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
  defp create_lib_ref(lib_name), do: ["libraries.", lib_name]

  defp create_lib_ref_from_artifact_id(artifact_id) do
    artifact_id
    |> create_lib_name
    |> create_lib_ref
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
