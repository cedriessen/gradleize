# Gradleize

Little helpers to migrate Opencast from a Maven based build to Gradle.

## Tasks

Create `.gradle` build file scaffolds for all modules

    $ mix run -e "Gradleize.create_module_build_files"

Make sure to configure the Opencast home directory in `config.exs`.

Create `.gradle` build file scaffold for a single module

    $ mix run -e 'Gradleize.create_module_build_file("/path/to/module")'

