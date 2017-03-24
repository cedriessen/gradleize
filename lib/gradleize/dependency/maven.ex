defmodule Gradleize.Dependency.Maven do
  @moduledoc """
  Handling Maven dependencies.
  """

  import SweetXml

  @doc """
  Parse a single `<dependency>` element into a `%Gradleize.Dependency{}` struct.
  """
  def parse_dependency(xml) do
    %Gradleize.Dependency{
      group_id: xml |> xpath(~x"./groupId/text()"s),
      artifact_id: xml |> xpath(~x"./artifactId/text()"s),
      version: xml |> xpath(~x"./version/text()"s),
      scope: xml |> xpath(~x"./scope/text()"s)
    }
  end

  @doc """
  Parse all `<dependency>` elements of a pom file.

  ## Opts

  - `section:` - either `:management` or `:dependencies`. Defaults to `:dependencies`.
                 Use `:management` to parse the `<dependencyManagement>` section.
  """
  def parse_dependencies(pom, opts \\ []) do
    xpath =
      case Keyword.get(opts, :section) do
        s when s in [nil, :dependencies] ->
          ~x"./dependencies/*"l
        _ ->
          ~x"./dependencyManagement/dependencies/*"l
      end
    {:ok, xml} = File.read(pom)
    xml
    |> parse
    |> xpath(xpath)
    |> Enum.map(&parse_dependency/1)
  end
end
