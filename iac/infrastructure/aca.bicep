import * as types from 'types.bicep'

@description('Environment configuration containing all necessary parameters')
param envConfig types.environmentConfiguration

@description('Model configuration for the container')
param modelConfig types.modelConfiguration

@description('The target port for the container')
param targetPort int = 8080

// func getAppName(cfg types.modelConfiguration, env types.environmentConfiguration) string => '${cfg.name}-${env.env}'

func getContainerConfiguration(cfg types.modelConfiguration, env types.environmentConfiguration) array => [
  {
    image: '${env.acrEndpoint}/${cfg.name}:${cfg.imageVersion}-${cfg.buildId}'
    name: cfg.name
    resources: {
        cpu: json('1.0')
        memory: '2Gi'
    }
    env: [
      {
        name: 'PORT'
        value: '8080'
      }
      {
        name: 'IMAGE_TAG'
        value: '${cfg.imageVersion}-${cfg.buildId}'
      }
      {
        name: 'PM_ENV'
        value: env.env
      }            
    ]
    // probes: [
    //   {
    //     type: 'liveness'
    //     httpGet: {
    //       path: '/api/health'
    //       port: 8080
    //     }
    //     initialDelaySeconds: 20
    //     periodSeconds: 10
    //   }
    // ]          
  }
]


var scaleRule = {
  minReplicas: 2
  maxReplicas: 10
  rules: [
  {
    name: 'http-scaler'
    http: {
      metadata: {
        concurrentRequests: '2'
      }
    }
  }]
} 

// Reference to existing ACR
resource existingAcr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: envConfig.acrName
}

// Log Analytics Workspace for Container Apps Environment
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${envConfig.environmentName}'
  location: envConfig.location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Container Apps Environment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: envConfig.environmentName
  location: envConfig.location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: modelConfig.name
  location: envConfig.location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        allowInsecure: false
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
      }
      secrets: [
        {
          name: 'acr-password'
          value: existingAcr.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: existingAcr.properties.loginServer
          username: existingAcr.listCredentials().username
          passwordSecretRef: 'acr-password'
        }
      ]
    }
    template: {
      containers: getContainerConfiguration(modelConfig, envConfig)
      scale: {
        minReplicas: scaleRule.minReplicas
        maxReplicas: scaleRule.maxReplicas
        rules: scaleRule.rules
      }
    }
  }
}

// Outputs
output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output resourceGroupName string = envConfig.resourceGroup
output environmentName string = envConfig.environmentName
