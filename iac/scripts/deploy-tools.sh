function parse_yaml {
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
        }
    }'
}

function load_location_configuration {
    local buildDir=$1
    local location=$2
    eval $(parse_yaml $buildDir/vars/locations/location-$location.yaml "LOC_")
}

function load_global_configuration {
    local buildDir=$1
    eval $(parse_yaml $buildDir/vars/vars-global.yaml "GLB_")
}

function load_env_configuration {
    local buildDir=$1
    local env=$2
    envFileContent=$(cat $buildDir/vars/vars-$env.yaml)
    envFileContent=$(echo "${envFileContent//$'- template: locations\/location-$\{\{ parameters.location \}\}.yaml\n'/}")
    envFileContent=$(echo "${envFileContent//- name: /  }")
    envFileContent=$(echo "${envFileContent//$'\n  value'/}")
    envFileContent=$(echo "${envFileContent//$\{\{ /}")
    envFileContent=$(echo "${envFileContent//$\{\{/}")
    envFileContent=$(echo "${envFileContent// \}\}/}")
    envFileContent=$(echo "${envFileContent//\}\}/}")
    envFileContent=$(echo "${envFileContent//variables.location/$LOC_variables_location}")
    envFileContent=$(echo "${envFileContent//variables.shortLocation/$LOC_variables_shortLocation}")
    rm -f temp_var.yaml
    echo "$envFileContent" >> temp_var.yaml
    eval $(parse_yaml temp_var.yaml "ENV_")
}

function create_header {
    local name=$1
    local file=$2
    echo "using '$name.bicep'" >> $file
    echo "" >> $file
}

function create_env_config {
    local env=$1
    local file=$2
    echo "Creating environment configuration"
    echo "param envConfig = {" >> $file
    echo "  env: '$env'" >> $file
    echo "  resourceGroup: '$ENV_variables_resourceGroup'" >> $file
    echo "  location: '$LOC_variables_location'" >> $file
    echo "  shortLocation: '$LOC_variables_shortLocation'" >> $file
    echo "  environmentName: 'env-album-containerapps-$env'" >> $file
    # echo "  apiName: '$ENV_variables_apiName'" >> $file
    echo "  acrName: '$ENV_variables_acrName'" >> $file
    echo "  acrEndpoint: '$ENV_variables_dockerRegistryUrl'" >> $file
    echo "}" >> $file

    cp $file $buildDir/infrastructure/$file
}

function create_aca_config {
    local file=$1
    local buildId=$2
    echo "" >> $file
    echo "param modelConfig = {" >> $file
    echo "  name: '$ENV_variables_apiName'" >> $file
    echo "  imageVersion: '$GLB_variables_imageVersion'" >> $file
    echo "  buildId: '$buildId'" >> $file
    echo "  latestCommit: '$latestCommit'" >> $file
    echo "  endpoint: 'https://$ENV_variables_apiName.azurecontainerapps.io'" >> $file
    echo "  endpointName: '$ENV_variables_apiName'" >> $file
    echo "}" >> $file
}

