#!/bin/bash

env=$1
location=$2
buildId=$3

file=acr.bicepparam
buildDir=iac

. $buildDir/scripts/deploy-tools.sh


function build_params_file {
    rm -f $file

    create_header 'acr' $file
    create_env_config $env $file

    echo "Created configuration file:"
    echo ""
    cat $file

    cp $file $buildDir/infrastructure/$file
}

function run_deployment {
    echo "Deploying ACR..."
    az deployment group create --name arc_album_$buildId \
        --resource-group $ENV_variables_resourceGroup \
        --template-file $buildDir/infrastructure/acr.bicep \
        -p $buildDir/infrastructure/$file 
}

# run load
load_global_configuration $buildDir
load_location_configuration $buildDir $location
load_env_configuration $buildDir $env

# run deploy
build_params_file
run_deployment