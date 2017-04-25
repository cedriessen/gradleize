# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :gradleize,
  # project subject to gradleization
  project_home: "/Users/ced/dev/mh/opencast.gradle"

rc = "#{System.get_env("HOME")}/.gradleizerc"
if File.exists?(rc) do
  import_config "#{System.get_env("HOME")}/.gradleizerc"
end

# import_config "#{Mix.env}.exs"
