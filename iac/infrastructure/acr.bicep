import * as types from 'types.bicep'

@description('Environment configuration containing all necessary parameters')
param envConfig types.environmentConfiguration

@description('SKU for the Azure Container Registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user for the registry')
param adminUserEnabled bool = true

@description('Tags for the resources')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: envConfig.acrName
  location: envConfig.location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
  }
}

@description('The login server URL for the Azure Container Registry')
output loginServer string = acr.properties.loginServer

@description('The resource ID of the Azure Container Registry')
output acrId string = acr.id

@description('The name of the Azure Container Registry')
output acrName string = acr.name
