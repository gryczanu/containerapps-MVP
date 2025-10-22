#!/bin/bash

# parameters
project=$1
organizationUrl=$2
releaseName=$3

# variables
pageContent=$(cat wiki.md)
date=$(date +%Y%m%d-%H%M%S)

releaseDir="$organizationUrl$project/_apis/wiki/wikis/albums/pages?path=Releases/$releaseName"
pageUrlPostfix="&versionDescriptor.version=main&api-version=7.1"
pageName="ACA-doc-$date"
pageUrlPostfix="&versionDescriptor.version=main&api-version=7.1"

# Create release wiki page
releasePagePath="$releaseDir$pageUrlPostfix"
response=$(curl -u :$SYSTEM_ACCESSTOKEN -X PUT \
           -H "Content-Type: application/json" \
           -d "{ \"content\": \"\" }" \
           $releasePagePath)

echo $response

# Put content into wiki page
contentPath="$releaseDir/$pageName$pageUrlPostfix"
response=$(curl -u :$SYSTEM_ACCESSTOKEN -X PUT \
           -H "Content-Type: application/json" \
           -d "{ \"content\": \"$pageContent\" }" \
           $contentPath)

echo $response