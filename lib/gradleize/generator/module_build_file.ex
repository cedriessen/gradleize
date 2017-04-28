defmodule Gradleize.Generator.ModuleBuildFile do
  @moduledoc """
  Generator functions for Gradle module build files.
  """

  alias Gradleize.Dependencies
  alias Gradleize.Opencast
  alias Gradleize.Util

  @doc """
  Generate a `.gradle` build file in each module directory.

  The file is named after the module, e.g. `matterhorn-common.gradle`.

  ## Param
  - `module_home` - home directory of all project module directories
  """
  def generate_all(modules_home) do
    modules_home
    |> Util.list_module_directories
    |> Enum.each(&generate/1)
  end

  @doc """
  Generate a `.gradle` build file in the given module directory.

  The file is named after the module, e.g. `matterhorn-common.gradle`.

  ## Param
  - `module_dir` - path to the module directory
  """
  def generate(module_dir) do
    module_name = Path.basename(module_dir)
    build_file = "#{module_name}.gradle"
    module_dir
    |> Path.join(build_file)
    |> File.write!(create_build_file_template(module_name))
    IO.puts "Created #{build_file}"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp create_build_file_template(module_name) do
    description = create_description_for(module_name)
    dependencies =
      module_name
      |> Opencast.module_pom
      |> Dependencies.create_module_dependencies
      |> Util.indent_iolist
    """
    project.description = '#{description}'

    dependencies {
    #{dependencies}
    }
    """
  end

  # Derive a description from a module name.
  defp create_description_for(module_name) do
    module_name
    |> String.split("-")
    |> Enum.map(&make_word/1)
    |> Enum.join(" ")
  end

  # turn a module name fragment into a word suitable as description
  defp make_word("api"), do: "API"
  defp make_word("aws"), do: "AWS"
  defp make_word("lti"), do: "LTI"
  defp make_word("ui"), do: "UI"
  defp make_word("ng"), do: "NG"
  defp make_word("ffmpeg"), do: "FFmpeg"
  defp make_word("aai"), do: "AAI"
  defp make_word("db"), do: "DB"
  defp make_word("cas"), do: "CAS"
  defp make_word("ldap"), do: "LDAP"
  defp make_word("openid"), do: "OpenID"
  defp make_word("oaipmh"), do: "OAI-PMH"
  defp make_word("sox"), do: "SOX"
  defp make_word("smil"), do: "SMIL"
  defp make_word("video" <> word), do: concat_words("Video", word)
  defp make_word("user" <> word), do: concat_words("User", word)
  defp make_word("url" <> word), do: concat_words("URL", word)
  defp make_word("text" <> word), do: concat_words("Text", word)
  defp make_word("silence" <> word), do: concat_words("Silence", word)
  defp make_word("service" <> word), do: concat_words("Service", word)
  defp make_word("workflow" <> word), do: concat_words("Workflow", word)
  defp make_word(word), do: String.capitalize(word)

  defp concat_words(prefix, ""), do: prefix
  defp concat_words(prefix, suffix), do: prefix <> " " <> String.capitalize(suffix)
end
