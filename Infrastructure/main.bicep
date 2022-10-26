param environmentName string
param actionGroupName string
param actionGroupEmail string



param location string = resourceGroup().location

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  location: location
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

var alertRuleName = '$demoalert-{environmentName}-alert'
resource alertProcessingRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: alertRuleName
  location: location
  properties: {
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          actionGroup.id
        ]
      }
    ]
    conditions: [
      {
        field: 'MonitorService'
        operator: 'Equals'
        values: [
          'Azure Backup'
        ]
      }
    ]
    enabled: true
    scopes: [
      subscription().id
    ]
  }
}
