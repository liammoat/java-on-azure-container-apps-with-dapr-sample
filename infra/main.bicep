param location string = resourceGroup().location
param resourcePrefix string = 'a${uniqueString(resourceGroup().id)}'

param registry_server string
param registry_username string

@secure()
param registry_password string

var containerAppsEnvName = '${resourcePrefix}-cae'
var logAnalyticsWorkspaceName = '${resourcePrefix}-logs'
var appInsightsName = '${resourcePrefix}-ai'
var storageAccountName = '${resourcePrefix}sa'

module containerAppsEnvModule 'modules/containerAppsEnv.bicep' = {
  name: '${deployment().name}--containerAppsEnv'
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
  }
}

module statestoreModule 'modules/dapr-components/statestore.bicep' = {
  name: '${deployment().name}--statestore'
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    containerAppsEnvModule
  ]
}

module webapiModule 'modules/container-apps/webapi.bicep' = {
  name: '${deployment().name}--webapi'
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    registry_server: registry_server
    registry_username: registry_username
    registry_password: registry_password
  }
  dependsOn: [
    statestoreModule
  ]
}

module webappModule 'modules/container-apps/webapp.bicep' = {
  name: '${deployment().name}--webapp'
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    registry_server: registry_server
    registry_username: registry_username
    registry_password: registry_password
  }
  dependsOn: [
    webapiModule
  ]
}
