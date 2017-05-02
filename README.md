# Gradleize

Little helpers to migrate Opencast from a Maven based build to Gradle.

## Tasks

### Build Files

Create `.gradle` build file scaffolds for all modules and the corresponding
`gradle/dependencies.gradle` file:

    $ mix run -e 'Gradleize.generate_module_build_files()'

Make sure to configure the Opencast home directory in `config.exs`.


### Feature Tree

Run the following command to display the feature tree starting with top-level features.
A top-level feature is a feature which is not referenced by any other.

    $ mix run -e 'Gradleize.Features.dependency_tree(Gradleize.Opencast.feature_xml())'

