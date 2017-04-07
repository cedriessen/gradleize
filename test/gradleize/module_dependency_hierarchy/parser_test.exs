defmodule Gradleize.ModuleDependencyHierarchy.ParserTest do
  use ExUnit.Case
  use Combine

  alias Gradleize.ModuleDependencyHierarchy.Parser

  test "module without dependency" do
    assert [ {"entwine-annotations-api", []} ] == Combine.parse("[entwine-annotations-api, []]", Parser.module())
    assert [ {"entwine-annotations-api", []} ] == Combine.parse("[entwine-annotations-api,[]]", Parser.module())
  end

  test "module with single dependency" do
    assert [ {"entwine-annotations-api", ["matterhorn-common"]} ] ==
      Combine.parse("[entwine-annotations-api, [matterhorn-common]]", Parser.module())

    assert [ {"entwine-annotations-api", ["matterhorn-common"]} ] ==
      Combine.parse(" [  entwine-annotations-api,[matterhorn-common] ]", Parser.module())
  end

  test "module with multiple dependencies" do
    assert [ {"entwine-distribution-service-s3", ["matterhorn-distribution-service-api", "matterhorn-workspace-api"]} ] ==
      Combine.parse("[entwine-distribution-service-s3, [matterhorn-distribution-service-api, matterhorn-workspace-api]]", Parser.module())

    assert [ {"entwine-distribution-service-s3", ["matterhorn-distribution-service-api", "matterhorn-workspace-api"]} ] ==
      Combine.parse("[entwine-distribution-service-s3,[matterhorn-distribution-service-api  ,matterhorn-workspace-api]]", Parser.module())
  end

  test "single module list" do
    expected = [ {"entwine-annotations-api", ["matterhorn-common"]} ]
    assert expected == Parser.parse("[[entwine-annotations-api, [matterhorn-common]]]")
  end

  test "multiple modules list" do
    expected = [
      {"entwine-annotations-api", ["matterhorn-common"]},
      {"entwine-distribution-service-s3", ["matterhorn-distribution-service-api", "matterhorn-workspace-api"]}
    ]
    assert expected == Parser.parse("[[entwine-annotations-api, [matterhorn-common]]  , [entwine-distribution-service-s3,[matterhorn-distribution-service-api  ,matterhorn-workspace-api]]]")
  end
end
