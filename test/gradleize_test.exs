defmodule GradleizeTest do
  use ExUnit.Case

  doctest Gradleize

  test "create library definitions from main pom" do
    output =
      Gradleize.Opencast.main_pom()
      |> Gradleize.Dependencies.create_library_definitions
      |> :erlang.iolist_to_binary

    assert output =~ "libraries.commons_lang3 = 'org.apache.commons:commons-lang3:3.4'"
    assert output =~ "libraries.cxf_rt_frontend_jaxrs = \"org.apache.cxf:cxf-rt-frontend-jaxrs:${versions.cxf}\""
    assert output =~ "${versions.osgi_core}"
  end
end
