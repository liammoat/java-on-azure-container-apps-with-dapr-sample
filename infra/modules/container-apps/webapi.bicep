param containerAppsEnvName string
param location string

param registry_server string
param registry_username string

@secure()
param registry_password string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource webapp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'webapp'
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      dapr: {
        enabled: true
        appId: 'webapp'
        appProtocol: 'http'
        appPort: 8080
      }
      secrets: [
        {
          name: 'registrypassword'
          value: registry_password
        }
      ]
      registries: [
        {
          server: registry_server
          username: registry_username
          passwordSecretRef: 'registrypassword'
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${registry_server}/java-app/webapp:v1'
          name: 'webapp'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
