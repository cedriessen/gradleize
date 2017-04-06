defmodule Gradleize.BND do
  @moduledoc """
  Extract BND instructions from Maven bundle plugin (maven-bundle-plugin) and create
  standalone bnd files for the Gradle build.

  Main entry point: `convert_module_poms/1`.
  """

  alias Gradleize.Opencast

  # instructions listed here will be discarded
  @discard_instructions [
    :"Build-Number",
    :"Bundle-SymbolicName"
  ]

  # instructions listed here will be commented out
  @disable_instructions [
    :"Embed-Dependency",
    :"_exportcontents",
    :"Private-Package",
    :"Import-Package"
  ]

  @doc """
  Scan all subdirectories of `module_base_dir` for `pom.xml` files. Extract the BND
  instructions section of the maven-bundle-plugin, transform them into a `bnd.bnd` file
  and write it to the module's root (next to the pom).

  ## Discard instructions

  Next to the following instructions, empty instructions will always be discarded:
  `#{@discard_instructions |> Enum.map(&Atom.to_string/1) |> Enum.join(", ")}`.
  """
  def convert_module_poms(modules_home \\ Opencast.modules_home()) do
    modules_home
    |> Gradleize.Util.list_module_directories
    |> Stream.map(fn module_dir ->
         {module_dir, read_instructions_from_module_pom(module_dir)}
       end)
    |> Stream.map(thread(&discard_instructions/1))
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

  defp write_bnd_file(module_dir, content) do
    IO.puts("Writing bnd.bnd to #{module_dir}")
    module_dir
    |> Path.join("bnd.bnd")
    |> File.write(content)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp discard_instructions(instructions) do
    instructions
    |> Enum.filter(&discard_instruction/1)
  end

  defp discard_instruction({_instruction, ""}), do: false
  defp discard_instruction({instruction, _value}) do
    not(@discard_instructions |> Enum.member?(instruction))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp rewrite_instructions(instructions) do
    instructions
    |> Enum.map(&rewrite_instruction/1)
  end

  defp rewrite_instruction({instruction = :"Export-Package", value}) do
    rewritten = String.replace(value, ~r/;version=\$\{project.version\}/, "")
    {instruction, rewritten}
  end
  defp rewrite_instruction(instruction) do
    instruction
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Take a keyword list of BDN instructions and create a BND instruction document.
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

  defp write_instruction({instruction, value}) do
    prefix = line_prefix(instruction)
    [
      prefix,
      Atom.to_string(instruction), ?:,
      write_value(value, prefix), ?\n
    ]
  end

  # prefix - line prefix
  defp write_value(value, prefix) do
    value
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> case do
         [single_line] ->
           [" ", single_line, ?\n]
         multiple_lines ->
           value_block =
             multiple_lines
             |> Enum.map(fn line -> [prefix, "  ", line] end)
             |> Enum.intersperse("\\\n")
           ["\\\n", value_block, ?\n]
       end
  end

  defp line_prefix(instruction) when instruction in @disable_instructions, do: ?#
  defp line_prefix(_instruction), do: ""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
