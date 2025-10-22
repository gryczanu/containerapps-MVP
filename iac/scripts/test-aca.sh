#!/bin/bash

# Test Container Apps deployment script
# Parameters: apiName resourceGroup imageVersion

apiName=$1
resourceGroup=$2
imageVersion=$3

echo "Testing Container Apps deployment..."
echo "API Name: $apiName"
echo "Resource Group: $resourceGroup"
echo "Image Version: $imageVersion"

# Wait for deployment to complete
echo "Waiting for deployment to stabilize..."
sleep 15

# Get revision status
echo "Checking revision status..."
revisions_json=$(az containerapp revision list \
  --name $apiName \
  --resource-group $resourceGroup \
  --output json)

revisions_output=$(echo "$revisions_json" | jq -r '.[] | "\(.name)\t\(.properties.trafficWeight // "N/A")\t\(.properties.createdTime)\t\(.properties.runningState)"' | column -t -s $'\t')

echo "$revisions_output"

# Check for failed revisions using the same JSON data
failed_revisions=$(echo "$revisions_json" | jq -r '.[] | select(.properties.runningState == "Failed") | .name')

if [ ! -z "$failed_revisions" ]; then
  echo "ERROR: Found failed revisions:"
  echo "$failed_revisions"
  echo "Deployment has failed revisions. Exiting..."
  exit 1
fi

# Get the application URL
echo "Getting application URL..."
APP_URL=$(az containerapp show \
  --name $apiName \
  --resource-group $resourceGroup \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

if [ -z "$APP_URL" ]; then
  echo "ERROR: Could not retrieve application URL. Checking ingress configuration..."
  az containerapp show \
    --name $apiName \
    --resource-group $resourceGroup \
    --query properties.configuration.ingress \
    --output json
  exit 1
else
  echo "Application deployed successfully!"
  echo "Test endpoints:"
  echo "  Albums: https://$APP_URL/albums"
  
  # Test the endpoints
  echo "Testing albums endpoint..."
  curl -f -s "https://$APP_URL/albums" | head -20 || echo "Albums endpoint test failed"
fi

# Show recent logs
echo "Recent application logs:"
az containerapp logs show \
  --name $apiName \
  --resource-group $resourceGroup \
  --tail 20 || echo "Could not retrieve logs"

echo "Container Apps testing completed."