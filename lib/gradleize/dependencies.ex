defmodule Gradleize.Dependencies do
  @moduledoc """
  Transforming Maven dependency declarations to Gradle.
  """

  alias Gradleize.Dependency.Maven
  alias Gradleize.Dependency.Gradle
  alias Gradleize.Dependency

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

  Return an IO list.
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
  # Return a single elemented list in case the given dependency can be transformed, or [] if not
  defp create_dependency_declaration(dep) do
    case Gradle.create_configuration_name(dep) do
      nil ->
        []
      configurationName ->
        dependency =
          dep
          |> rewrite_version
          |> create_dependency_string_for_declaration
        [[configurationName, " ", dependency]]
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


  # Create a Gradle library definition from a parsed Maven dependency.
  defp create_library_definition(dep) do
    lib_ref = create_lib_ref(artifact: dep.artifact_id)
    dependency =
      dep
      |> rewrite_version
      |> Gradle.create_quoted_dependency_string
    [lib_ref, " = ", dependency]
  end

  defp create_quoted_dependency_string

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
