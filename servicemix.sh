#!/usr/bin/env bash

echo "SERVICEMIX"
curl "http://search.maven.org/solrsearch/select?q=g:%22org.apache.servicemix.bundles%22%20AND%20fc:%22$1%22&rows=500&wt=json"|python -m json.tool

echo
echo "ALL"
curl "http://search.maven.org/solrsearch/select?q=fc:%22$1%22&rows=500&wt=json"|python -m json.tool
