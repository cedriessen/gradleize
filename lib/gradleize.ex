defmodule Gradleize do
  @moduledoc """
  TODO
  """

  @doc """
  Create module include statements for `settings.gradle`.

  ## Param
  - `module_home` - home directory of all project module directories
  """
  def create_module_includes(module_home) do
    module_home
    |> Gradleize.Util.list_module_directories
    |> Enum.map(fn module_dir ->
         module_name = Path.basename(module_dir)
         "include ':#{module_name}'"
       end)
    |> Enum.each(&IO.puts/1)
  end

  @doc """
  Create a `.gradle` build file in each module directory.
  Name the file after the module, e.g. `matterhorn-common.gradle`.

  ## Param
  - `module_home` - home directory of all project module directories
  """
  def create_module_build_files(module_home) do
    module_home
    |> Gradleize.Util.list_module_directories
    |> Enum.each(fn module_dir ->
         module_name = Path.basename(module_dir)
         build_file = "#{module_name}.gradle"
         module_dir
         |> Path.join(build_file)
         |> File.write!(build_file_template(module_name))
       end)
  end

  defp build_file_template(module_name) do
    description =
      module_name
      |> String.split("-")
      |> Enum.map(&make_word/1)
      |> Enum.join(" ")
    """
    project.description = '#{description}'

    dependencies {
    }
    """
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
