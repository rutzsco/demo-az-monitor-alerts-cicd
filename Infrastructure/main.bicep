param environmentName string
param actionGroupName string
param actionGroupEmail string
param sqlServerName string = 'rutzscosqldb'
param databaseName string = 'DB001'

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    enabled: true
    groupShortName: actionGroupName
    emailReceivers: [
      {
        name: actionGroupName
        emailAddress: actionGroupEmail
        useCommonAlertSchema: true
      }
    ] 
  }
}

var alertRuleName = 'metricAlertDBCPU-${environmentName}-alert'
var sqlServerExternalId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Sql/servers/${sqlServerName}'

resource metricAlertsDBCPU 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: alertRuleName
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      '${sqlServerExternalId}/databases/${databaseName}'
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 70
          name: 'Metric1'
          metricNamespace: 'microsoft.sql/servers/databases'
          metricName: 'cpu_percent'
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: 'eastus'
    actions: [
      {
        actionGroupId: actionGroup.id
        webHookProperties: {
        }
      }
    ]
  }
}
