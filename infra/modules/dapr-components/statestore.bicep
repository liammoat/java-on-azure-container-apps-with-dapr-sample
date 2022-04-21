param containerAppsEnvName string
param storageAccountName string
param location string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource daprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'statestore'
  parent: cappsEnv
  properties: {
    componentType: 'state.azure.blobstorage'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'
    secrets: [
      {
        name: 'storageaccountkey'
        value: listKeys(sa.id, sa.apiVersion).keys[0].value
      }
    ]
    metadata: [
      {
        name: 'accountName'
        value: sa.name
      }
      {
        name: 'containerName'
        value: 'my-container'
      }
      {
        name: 'accountKey'
        secretRef: 'storageaccountkey'
      }
    ]
    scopes: [
      'webapi'
    ]
  }
}
