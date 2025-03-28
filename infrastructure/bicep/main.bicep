// Parameters
param location string = 'eastus2'
param environmentName string = 'prod'
param sqlAdminLogin string
@secure()
param sqlAdminPassword string

// Variables
var appServicePlanName = 'asp-${environmentName}'
var webAppName = 'app-${environmentName}'
var sqlServerName = 'sql-${environmentName}-${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'db-${environmentName}'
var alertRuleName = 'alert-high-requests'

// Resources
module appService 'modules/appService.bicep' = {
  name: 'appServiceDeploy'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
  }
}

module sqlServer 'modules/sqlServer.bicep' = {
  name: 'sqlServerDeploy'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoringDeploy'
  params: {
    location: location
    alertRuleName: alertRuleName
    webAppName: webAppName
  }
}

// Outputs
output webAppHostName string = appService.outputs.webAppHostName
output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn
output databaseName string = sqlServer.outputs.databaseName 
