defmodule Gradleize.Dependency.Maven do
  @moduledoc """
  Maven dependency handling.
  """

  import SweetXml
  alias Gradleize.Dependency

  @doc """
  Parse a single `<dependency>` element into a `%Gradleize.Dependency{}` struct.
  """
  def parse_dependency(xml) do
    exclusions =
      xml
      |> xpath(~x"./exclusions/exclusion"l)
      |> Enum.map(fn exclusion ->
           {
             exclusion |> xpath(~x"./groupId/text()"s),
             exclusion |> xpath(~x"./artifactId/text()"s)
           }
         end)
    %Dependency{
      group_id: xml |> xpath(~x"./groupId/text()"s),
      artifact_id: xml |> xpath(~x"./artifactId/text()"s),
      version: xml |> xpath(~x"./version/text()"s),
      scope: xml |> xpath(~x"./scope/text()"s),
      exclusions: exclusions
    }
    |> Dependency.fix_empty
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
