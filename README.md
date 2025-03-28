# Skedda Platform Engineer Challenge

This repository contains the solution for the Skedda Platform Engineer technical challenge. It implements an Azure-based Infrastructure as Code (IaC) solution for a simple web application that queries a database.

## Prerequisites

1. **Azure Subscription**
   - Resource Group: `SamuelB`
   - Subscription ID: `<SUBSCRIPTION_ID>`
   - Service Principal credentials (provided separately)

2. **Azure DevOps Setup Requirements**
   - Variable Group named "PlatformChallenge" with:
     - sqlAdminLogin
     - sqlAdminPassword (as secret)
   - Service Connection to Azure using the provided service principal
   - Permissions needed:
     - Create/manage Variable Groups
     - Create/manage Service Connections
     - Create/manage Pipelines

## Solution Components

1. **Infrastructure as Code (Bicep)**
   - App Service (Free tier)
   - SQL Server with geo-replication
   - Azure Monitor Alert for request monitoring

2. **Azure DevOps Pipeline**
   - Single pipeline for infrastructure and application deployment
   - Uses variable groups for sensitive information
   - Supports region-based deployment

3. **Disaster Recovery**
   - SQL Server geo-replication to Central US (paired region)
   - Automated failover script
   - Minimal downtime recovery process

## Project Structure

```
.
├── infrastructure/
│   ├── bicep/
│   │   ├── main.bicep                 # Main infrastructure template
│   │   └── modules/
│   │       ├── appService.bicep       # App Service configuration
│   │       ├── sqlServer.bicep        # SQL Server with geo-replication
│   │       └── monitoring.bicep       # Azure Monitor alerts
│   ├── pipelines/
│   │   └── azure-pipelines.yml        # CI/CD pipeline definition
│   └── scripts/
│       └── disaster-recovery.sh       # DR failover script
└── PlatformChallengeWebApp/           # .NET 9 web application
```

## Setup Instructions

1. **Azure DevOps Configuration**
   ```bash
   # Create Variable Group (replace placeholders with actual values)
   az pipelines variable-group create --name "PlatformChallenge" --variables sqlAdminLogin=<ADMIN_LOGIN> --authorize true
   az pipelines variable-group variable create --group-id "PlatformChallenge" --name sqlAdminPassword --value "<ADMIN_PASSWORD>" --secret true

   # Create Service Connection (replace placeholders with actual values)
   az devops service-endpoint azurerm create \
     --name "Platform Challenge Connection" \
     --azure-rm-service-principal-id "<SERVICE_PRINCIPAL_ID>" \
     --azure-rm-subscription-id "<SUBSCRIPTION_ID>" \
     --azure-rm-subscription-name "Platform Candidate Playground" \
     --azure-rm-tenant-id "<TENANT_ID>"
   ```

2. **Pipeline Setup**
   - Import the pipeline from `infrastructure/pipelines/azure-pipelines.yml`
   - Link the Variable Group to the pipeline
   - Run the pipeline to deploy infrastructure and application

3. **Manual Deployment (if needed)**
   ```bash
   # Login to Azure (replace placeholders with actual values)
   az login --service-principal -u "<SERVICE_PRINCIPAL_ID>" -p "<SERVICE_PRINCIPAL_SECRET>" --tenant "<TENANT_ID>"

   # Deploy infrastructure (replace placeholders with actual values)
   az deployment group create \
     --resource-group SamuelB \
     --template-file infrastructure/bicep/main.bicep \
     --parameters \
       sqlAdminLogin=<ADMIN_LOGIN> \
       sqlAdminPassword="<ADMIN_PASSWORD>" \
       location=eastus2
   ```

## Disaster Recovery Process

1. **Automated Failover**
   ```bash
   # Run the DR script
   ./infrastructure/scripts/disaster-recovery.sh
   ```

2. **Manual Failover Steps**
   1. Create new App Service in Central US
   2. Deploy application to new App Service
   3. Initiate database failover
   4. Update connection strings
   5. Verify application functionality

## Testing the Solution

1. **Infrastructure Deployment**
   - Verify resource creation in Azure Portal
   - Check App Service configuration
   - Validate SQL Server geo-replication

2. **Application Testing**
   - Access the web application
   - Verify database connectivity
   - Test request monitoring alert

3. **Disaster Recovery Testing**
   - Simulate primary region failure
   - Execute failover process
   - Verify application availability in secondary region

## Notes

- The solution uses the Free tier of App Service for cost optimization
- Geo-replication is configured for the SQL Database to support DR
- Azure Monitor alert is set to trigger at 20 requests within 5 minutes
- All sensitive information is stored in Azure DevOps Variable Groups
- Actual credentials and sensitive values should be provided separately and securely 