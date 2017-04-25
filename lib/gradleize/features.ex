defmodule Gradleize.Features do
  @moduledoc """
  Tools for Karaf's `feature.xml`.
  """

  import SweetXml

  @doc """
  - `feature_xml` - file name
  """
  def dependency_tree(feature_xml) do
    features = parse_feature_xml(feature_xml)
    top_level = top_level_features(features)
    features
    |> tree(top_level)
    |> show_tree("", [])
  end


  @doc """
  Return a list of top level feature names.

  # Params
  - `features` - parsed `feature.xml`
  """
  def top_level_features(features) do
    # calc set of all features someone depends on
    dependencies =
      features
      |> Enum.reduce(MapSet.new, fn {_f, ds}, acc ->
           ds
           |> MapSet.new(fn x -> x end)
           |> MapSet.union(acc)
         end)
    features
    |> Enum.flat_map(fn {f, _} ->
         if (MapSet.member?(dependencies, f)), do: [], else: [f]
       end)
  end

  # - - - - - - - - - - - -

  # %{feature => [feature]}
  defp parse_feature_xml(feature_xml) do
    feature_xml
    |> File.read!
    |> xpath(~x"/features/feature"l, feature: ~x"./@name"s, dependencies: ~x"./feature/text()"ls)
    |> Enum.reduce(%{}, fn %{feature: f, dependencies: ds}, acc ->
         acc
         |> Map.update(f, ds, fn v -> v ++ ds end)
       end)
  end

  # - - - - - - - - - - - -

  defp show_tree(tree, indent, already_shown) do
    for {feature, dependencies} <- tree,
        not(feature in already_shown) do
      IO.puts [indent, feature]
      for sub_tree <- dependencies do
        show_tree(sub_tree, ["  ", indent], [feature | already_shown])
      end
    end
  end

  # [%{"extron-allinone" => [%{"extron-core" => ...}, %{"opencast-allinone" => []}]}]
  defp tree(features, only \\ []) do
    features
    |> Stream.filter(fn {feature, _} ->
         only == [] or Enum.member?(only, feature)
       end)
    |> Enum.map(fn {feature, dependencies} ->
         {feature, do_tree(features, dependencies)}
       end)
  end

  defp do_tree(_features, []) do
    []
  end
  defp do_tree(features, [d | ds]) do
    [%{d => do_tree(features, Map.get(features, d, []))} | do_tree(features, ds)]
  end
end
