#!/bin/bash

env=$1
location=$2
buildId=$3
sourceVersion=$4

file=aca.bicepparam
buildDir=iac
latestCommit=${sourceVersion:0:7}

. $buildDir/scripts/deploy-tools.sh

function build_params_file {
    rm -f $file

    create_header 'aca' $file
    create_env_config $env $file
    create_aca_config $file $buildId

    echo "Created configuration file:"
    echo ""
    cat $file

    cp $file $buildDir/infrastructure/$file
}

function validate_deployment {
    echo "Validating Bicep template..."
    
    # Check if files exist
    if [ ! -f "$buildDir/infrastructure/aca.bicep" ]; then
        echo "ERROR: Template file not found: $buildDir/infrastructure/aca.bicep"
        exit 1
    fi
    
    if [ ! -f "$buildDir/infrastructure/$file" ]; then
        echo "ERROR: Parameters file not found: $buildDir/infrastructure/$file"
        exit 1
    fi
    
    echo "Running template validation..."
    az deployment group validate \
        --resource-group $ENV_variables_resourceGroup \
        --template-file $buildDir/infrastructure/aca.bicep \
        -p $buildDir/infrastructure/$file \
        --verbose

    echo "Template validation successful!"
}

function run_deployment {
    local dgSuffix=$1
    local deploymentName="aca_album_$buildId$dgSuffix"
    
    echo "Running ACA deployment..."

    az deployment group create \
        --name $deploymentName \
        --resource-group $ENV_variables_resourceGroup \
        --template-file $buildDir/infrastructure/aca.bicep \
        -p $buildDir/infrastructure/$file \
        --verbose

    echo "Deployment completed successfully!"
}

load_global_configuration $buildDir
if [ $? -ne 0 ]; then
    echo "      ERROR: load_global_configuration failed"
    exit 1
fi
load_location_configuration $buildDir $location
if [ $? -ne 0 ]; then
    echo "      ERROR: load_location_configuration failed"
    exit 1
fi
load_env_configuration $buildDir $env
if [ $? -ne 0 ]; then
    echo "      ERROR: load_env_configuration failed"
    exit 1
fi

build_params_file
if [ $? -ne 0 ]; then
    echo "      ERROR: build_params_file failed"
    exit 1
fi

validate_deployment
if [ $? -ne 0 ]; then
    echo "      ERROR: validate_deployment failed"
    exit 1
fi

run_deployment 'deploy'
if [ $? -ne 0 ]; then
    echo "      ERROR: run_deployment failed"
    exit 1
fi