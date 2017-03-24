defmodule GradleizeTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  doctest Gradleize

  test "create library definitions from main pom" do
    test = fn ->
      Gradleize.Opencast.main_pom()
      |> Gradleize.Dependencies.create_library_definitions
    end

    output = capture_io(test)
    assert output =~ "libraries.commons_lang3 = 'org.apache.commons:commons-lang3:3.4'"
    assert output =~ "libraries.cxf_rt_frontend_jaxrs = \"org.apache.cxf:cxf-rt-frontend-jaxrs:${versions.cxf}\""
    assert output =~ "${versions.osgi_core}"
  end

  test "create dependency definitions for matterhorn-common" do
    test = fn ->
      "matterhorn-common"
      |> Gradleize.Opencast.module_pom
      |> Gradleize.Dependencies.create_module_dependencies
    end
    test.()
#    assert capture_io(test) =~ "compile libraries.guava"
  end
end
