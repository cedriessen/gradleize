defmodule Gradleize.Generator.DependenciesFile do
  @moduledoc """
  Generator functions for Gradle dependencies file.
  """


  @doc """
  Generate Gradle dependencies file from a pom.

  The depencencies file contains both library declarations and library version numbers.

  Value are extracted from the pom's `<properties>` section. Each property ending with `.version`
  is considered to be a version property.

  ## Params
  - `dependencies_file` - path of the dependencies file to generate
  - `pom` - path to `pom.xml`, usually the main pom of the project
  """
  @spec generate(binary, binary) :: iolist
  def generate(dependencies_file, pom) do
    libraries =
      Gradleize.Dependencies.create_library_definitions(pom)
    versions =
      pom
      |> Gradleize.Dependency.Maven.parse_properties
      |> Enum.filter(fn {prop, _v} -> String.ends_with?(prop, ".version") end)
      |> Enum.sort
      |> Enum.map(fn {prop, value} ->
           gradle_prop = Gradleize.Dependencies.rewrite_version_property(prop)
           [gradle_prop, " = '", value, "'\n"]
         end)

    content = [file_header, versions, "\n\n", libraries]
    File.write!(dependencies_file, content)
  end

  defp file_header do
    """
    /**
     * Common versions and dependencies
     *
     * This file contains versions and definition of dependencies which are used across the whole project. It is applied
     * in the root project build file and thus available for all projects.
     */

    // Define extra properties, which are available through the whole project, see
    // https://docs.gradle.org/current/userguide/writing_build_scripts.html#sec:extra_properties
    ext {
      versions = [:]
      libraries = [:]
    }

    // PLEASE NOTE:
    //   Dependencies/versions managed in this file DO NOT affect the Karaf runtime. Those are maintained
    //   in the corresponding Maven project fount in `${projectRoot}/assemblies`.

    """
  end
end
# pom.xml
#<project>
#<properties>
#    <entwine.version>1.0.7</entwine.version>
#    <checkstyle.skip>false</checkstyle.skip>
#    <jmeter.home>${project.build.directory}/jakarta-jmeter-${jmeter.version}</jmeter.home>
#    <json-simple.version>1.1.1</json-simple.version>
#    <matterhorn.basedir>${basedir}</matterhorn.basedir>
#    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
#    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
#    <opencast.nexus.url>http://nexus.virtuos.uos.de:8081</opencast.nexus.url> <!-- TODO: This is only a workaround! Set back to http://nexus.opencast.org as soon as mirrors are working again -->
#    <eclipselink.version>2.6.4</eclipselink.version>
#    <commons-collection.version>3.2.2</commons-collection.version>
#    <commons-compress.version>1.9</commons-compress.version>
#    <httpcomponents-httpcore.version>4.4.6</httpcomponents-httpcore.version>
#    <httpcomponents-httpclient.version>4.5.2</httpcomponents-httpclient.version>
#    <jmeter.version>2.4</jmeter.version>
#    <osgi.compendium.version>6.0.0</osgi.compendium.version>
#    <osgi.core.version>6.0.0</osgi.core.version>
#    <osgi.enterprise.version>6.0.0</osgi.enterprise.version>
#    <karaf.version>4.1.1</karaf.version>
#    <pax.web.version>6.0.3</pax.web.version>
#    <cxf.version>3.1.9</cxf.version>
#    <aws.version>1.10.44</aws.version>
#    <jackson.version>2.7.0</jackson.version>
#    <functional.version>1.4.2</functional.version>
#    <swagger.annotations.version>1.5.12</swagger.annotations.version>
#    <swagger.codegen.plugin.version>2.2.2</swagger.codegen.plugin.version>
#    <javaslang.version>2.0.5</javaslang.version>
#
#    <xerces.version>2.11.0_1</xerces.version>
#    <servicemix.specs.version>2.7.0</servicemix.specs.version>
#    <xalan.bundle.version>2.7.2_3</xalan.bundle.version>
#    <xalan-serializer.bundle.version>2.7.2_1</xalan-serializer.bundle.version>
#    <jna.version>4.3.0</jna.version>
#  </properties>
