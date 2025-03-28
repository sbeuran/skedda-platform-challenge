param location string
param sqlServerName string
param sqlDatabaseName string
param administratorLogin string
@secure()
param administratorLoginPassword string

var secondaryLocation = 'centralus' // Paired region for disaster recovery

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

// Allow Azure services to access the server
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Primary Database
resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    requestedBackupStorageRedundancy: 'Geo'
  }
}

// Secondary SQL Server for geo-replication
resource secondarySqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: '${sqlServerName}-secondary'
  location: secondaryLocation
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

// Allow Azure services to access the secondary server
resource secondaryFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: secondarySqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Geo-replication link
resource geoReplication 'Microsoft.Sql/servers/databases/geoBackupPolicies@2022-05-01-preview' = {
  name: 'Default'
  parent: database
  properties: {
    state: 'Enabled'
  }
}

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = database.name 
