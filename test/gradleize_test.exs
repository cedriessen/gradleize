defmodule GradleizeTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  doctest Gradleize

  test "create library definitions" do
    test = fn ->
      Gradleize.Util.main_pom()
      |> Gradleize.Dependencies.create_library_definitions
    end

    output = capture_io(test)
    assert output =~ "libraries.commons_io"
    assert output =~ "${versions.osgi_core}"
  end

  test "create dependency definitions" do
    test = fn ->
      "matterhorn-common"
      |> Gradleize.Util.module_pom
      |> Gradleize.Dependencies.create_module_dependencies
    end
    test.()
#    assert capture_io(test) =~ "compile libraries.guava"
  end
end
