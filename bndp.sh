#!/usr/bin/env bash

# BND print

echo "GRADLE"
gradle=$(bnd print --impexp /Users/ced/dev/mh/opencast/modules/$1/build/libs/$1-2.2-SNAPSHOT.jar)
echo "$gradle"

echo
echo "MAVEN"
maven=$(bnd print --impexp /Users/ced/dev/mh/opencast/tmp/$1-2.2-SNAPSHOT.jar)
echo "$maven"

echo
echo "DIFF Maven <-> Gradle"
diff  -y <(echo "$maven" ) <(echo "$gradle")
