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
             xpath(exclusion, ~x"./groupId/text()"s),
             xpath(exclusion, ~x"./artifactId/text()"s)
           }
         end)
    Dependency.new
    |> Dependency.group_id(xpath(xml, ~x"./groupId/text()"s))
    |> Dependency.artifact_id(xpath(xml, ~x"./artifactId/text()"s))
    |> Dependency.version(xpath(xml, ~x"./version/text()"s))
    |> Dependency.scope(xpath(xml, ~x"./scope/text()"s))
    |> Dependency.exclusions(exclusions)
  end

  @doc """
  Parse all `<dependency>` elements of a pom file.

  ## Params
  - `pom` - pom file name

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
    pom
    |> parse_pom
    |> xpath(xpath)
    |> Enum.map(&parse_dependency/1)
  end

  @doc """
  Read a pom file and return it as XML.
  """
  def parse_pom(pom) do
    {:ok, xml} = File.read(pom)
    xml
    |> parse
  end
end
