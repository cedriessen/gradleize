defmodule Gradleize.Misc do
  @moduledoc """
  Miscellanous transformations.
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
end
