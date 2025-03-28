param location string
param alertRuleName string
param webAppName string

// Action Group for email notifications
resource emailActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: 'email-action-group'
  location: 'global'
  properties: {
    groupShortName: 'email'
    enabled: true
    emailReceivers: [
      {
        name: 'emailReceiver'
        emailAddress: 'sbeuran@gmail.com'
        useCommonAlertSchema: true
      }
    ]
  }
}

// Metric Alert for high request rate
resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertRuleName
  location: 'global'
  properties: {
    description: 'Alert when request count exceeds threshold'
    severity: 2
    enabled: true
    scopes: [
      resourceId('Microsoft.Web/sites', webAppName)
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'High request count'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Requests'
          operator: 'GreaterThan'
          threshold: 20
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: emailActionGroup.id
      }
    ]
  }
} 
