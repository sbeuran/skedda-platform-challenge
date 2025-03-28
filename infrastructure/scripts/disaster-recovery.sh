#!/bin/bash

# This script performs disaster recovery failover from East US 2 to Central US
# It should be run when the primary region (East US 2) is down

# Parameters (these should be passed in or retrieved from Azure KeyVault in a real scenario)
PRIMARY_REGION="eastus2"
SECONDARY_REGION="centralus"
RESOURCE_GROUP="SamuelB"
APP_NAME="app-prod"
SQL_SERVER_PRIMARY="sql-prod-"  # The actual name will have a unique string appended
SQL_SERVER_SECONDARY="sql-prod-secondary-"  # The actual name will have a unique string appended
DATABASE_NAME="db-prod"

# 1. Create a new App Service Plan and Web App in the secondary region
echo "Creating new App Service infrastructure in $SECONDARY_REGION..."
az appservice plan create \
  --name "asp-prod-dr" \
  --resource-group $RESOURCE_GROUP \
  --location $SECONDARY_REGION \
  --sku F1

az webapp create \
  --name "$APP_NAME-dr" \
  --resource-group $RESOURCE_GROUP \
  --plan "asp-prod-dr"

# 2. Deploy the application to the new web app
echo "Deploying application to secondary region..."
# Note: The actual deployment command would depend on your CI/CD setup
# This is just an example:
az webapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name "$APP_NAME-dr" \
  --src "app.zip"

# 3. Initiate database failover
echo "Initiating database failover..."
az sql db failover \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_PRIMARY \
  --name $DATABASE_NAME \
  --target-server $SQL_SERVER_SECONDARY

# 4. Update application settings with new database connection string
echo "Updating application settings..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name "$APP_NAME-dr" \
  --settings "DbConnectionString=Server=$SQL_SERVER_SECONDARY.database.windows.net;Database=$DATABASE_NAME;..."

echo "Disaster recovery failover complete!"
echo "New application URL: https://$APP_NAME-dr.azurewebsites.net" 