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
    echo "Getting latest revision information..."
    revisions=$(az containerapp revision list --name $ENV_variables_apiName --resource-group $ENV_variables_resourceGroup --query "[0].{name:name, trafficWeight:properties.trafficWeight, createdTime:properties.createdTime, runningState:properties.runningState}" -o json)
    
    # Create wiki header
    cat > "$output_file" << EOF
# Container App Latest Revision - $ENV_variables_apiName

## Latest Revision Details

| Name | State | Creation | Traffic |
|------|-------|----------|---------|
EOF

    # Parse JSON and create table row for latest revision
    echo "$revisions" | jq -r '"| \(.name) | \(.runningState) | \(.createdTime) | \(.trafficWeight // 0)% |"' >> "$output_file"
    
    echo "" >> "$output_file"
    echo "*Generated: $(date)*" >> "$output_file"
}



# load_location_configuration $buildDir $location
load_env_configuration $buildDir $env
gen_wiki

cat "$output_file"