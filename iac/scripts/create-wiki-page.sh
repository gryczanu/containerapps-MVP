#!/bin/bash

# params
env=$1
location=$2
# appName=$3
# resourceGroup=$4

buildDir=iac

. $buildDir/scripts/deploy-tools.sh

output_file="wiki.md"
> "$output_file"

function gen_wiki {
    echo "Getting revision information..."
    revisions=$(az containerapp revision list --all --name $ENV_variables_apiName --resource-group $ENV_variables_resourceGroup --query "[].{name:name, trafficWeight:properties.trafficWeight, createdTime:properties.createdTime, runningState:properties.runningState}" -o json)
}

# load_location_configuration $buildDir $location
load_env_configuration $buildDir $env
gen_wiki

cat "$output_file"