defmodule Gradleize.FeaturesTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Gradleize.Features

  test "feature dependency tree" do
    test = fn ->
      "test/gradleize/feature.xml"
      |> Features.dependency_tree
    end
    expect = """
      extron-allinone
        extron-core
          opencast-core
            core
              ext-core
                http
                http-whiteboard
                scr
                webconsole
                cxf-jaxrs
                cxf-http-jetty
                jndi
                jpa
                eclipselink
                query-dsl
        opencast-allinone
          opencast-core
            core
              ext-core
                http
                http-whiteboard
                scr
                webconsole
                cxf-jaxrs
                cxf-http-jetty
                jndi
                jpa
                eclipselink
                query-dsl
          allinone
      """
    output = capture_io(test)
    assert output =~ expect 
  end
end
