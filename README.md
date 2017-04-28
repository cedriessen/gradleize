# Gradleize

Little helpers to migrate Opencast from a Maven based build to Gradle.

## Tasks

Create `.gradle` build file scaffolds for all modules and the corresponding
`gradle/dependencies.gradle` file:

    $ mix run -e 'Gradleize.generate_module_build_files()'

Make sure to configure the Opencast home directory in `config.exs`.

