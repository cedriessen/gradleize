defmodule Gradleize.BND do
  @moduledoc """
  Extract BND instructions from Maven bundle plugin (maven-bundle-plugin) and create
  standalone bnd files for the Gradle build.

  Main entry point: `convert_module_poms/1`.
  """

  alias Gradleize.Opencast

  @discard_instructions [
    :"Build-Number",
    :"Bundle-SymbolicName",
    :"Embed-Dependency"
  ]

  @doc """
  Scan all subdirectories of `module_base_dir` for `pom.xml` files. Extract the BND
  instructions section of the maven-bundle-plugin, transform them into a `bnd.bnd` file
  and write it to the module's root (next to the pom).

  ## Discard instructions

  Next to the following instructions, empty instructions will always be discarded:
  `#{@discard_instructions |> Enum.map(&Atom.to_string/1) |> Enum.join(", ")}.
  """
  def convert_module_poms(modules_home \\ Opencast.modules_home()) do
    modules_home
    |> Gradleize.Util.list_module_directories
    |> Stream.map(fn module_dir ->
         {module_dir, read_instructions_from_module_pom(module_dir)}
       end)
    |> Stream.map(thread(&filter_instructions/1))
    |> Stream.map(thread(&rewrite_instructions/1))
    |> Stream.map(thread(&create_bnd/1))
    |> Stream.map(fn {module_dir, bnd} ->
         write_bnd_file(module_dir, bnd)
       end)
    |> Stream.run
  end

  # little helper function to reduce clutter in the `convert_module_poms` stream mapping section
  # creates a function that treads through the `module_dir` parameter
  defp thread(fun) do
    fn {module_dir, payload} ->
      {module_dir, fun.(payload)}
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def write_bnd_file(module_dir, content) do
    IO.puts("Writing bnd.bnd to #{module_dir}")
    module_dir
    |> Path.join("bnd.bnd")
    |> File.write(content)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def filter_instructions(instructions) do
    instructions
    |> Enum.filter(&filter_instruction/1)
  end

  defp filter_instruction({instruction, ""}), do: false
  defp filter_instruction({instruction, _value}) do
    not(@discard_instructions |> Enum.member?(instruction))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def rewrite_instructions(instructions) do
    instructions
    |> Enum.map(&rewrite_instruction/1)
  end

  def rewrite_instruction({instruction = :"Export-Package", value}) do
    rewritten = String.replace(value, ~r/;version=\$\{project.version\}/, "")
    {instruction, rewritten}
  end
  def rewrite_instruction(instruction) do
    instruction
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Take a keyword list of BDN instructions and create a BND file.
  Return an IO list.

  ## Example output

      Export-Package:\\
        com.extron.entwine.videolounge.dataservice,\\
        com.extron.entwine.videolounge.dataservice.impl,\\
        com.extron.entwine.videolounge.dataservice.index.docs,\\
        com.extron.entwine.videolounge.dataservice.util

      Import-Package:\\
        !javax.annotation,\\
        *

      Provide-Capability: osgi.service;objectClass="com.extron.entwine.videolounge.dataservice.VideoloungeDataService"

      Service-Component: OSGI-INF/data-service.xml
  """
  def create_bnd(instructions) do
    instructions
    |> Enum.map(&write_instruction/1)
  end

  def write_instruction({instruction, value}) do
    [
      Atom.to_string(instruction), ":",
      append_value(value), "\n"
    ]
  end

  def append_value(value) do
    value
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> case do
         [single_line] ->
           [" ", single_line, "\n"]
         multiple_lines ->
           ["\\\n", write_value_block(multiple_lines), "\n"]
       end
  end

  def write_value_block(lines) do
    lines
    |> Enum.map(fn line -> ["  ", line] end)
    |> Enum.intersperse("\\\n")
  end

  import SweetXml

  @doc """
  Read all BDN instructions from the `pom.xml` located in `module_dir` and return them
  as a keyword list with the key being the instruction name, e.g. `:"Bundle-SymbolicName"`.
  """
  def read_instructions_from_module_pom(module_dir) do
    module_dir
    |> Path.join("pom.xml")
    |> File.stream!
    # extract only 'instructions' tags
    |> stream_tags([:instructions])
    |> Stream.flat_map(fn {_tag_name, instructions} ->
         parse_instructions(instructions)
       end)
    |> Enum.to_list
  end

  # Take an <instructions> XML node and return its subelements as a keyword list.
  defp parse_instructions(xml) do
    xml
    |> xpath(~x"./*"l)
    |> Enum.map(&parse_instruction/1)
  end

  # Parse a single instruction element into a keyword tuple `{:instruction, value}`.
  defp parse_instruction(xml) do
    instruction_name = xmlElement(xml, :name)
    instruction_value = xml |> xpath(~x"./text()"s) |> String.trim
    {instruction_name, instruction_value}
  end
end
