targetScope = 'managementGroup'

@description('parameters from deploy-prod.parameters.bicepparam')
param abbr string

param locations string

param storageBlobDataContributorID string
param readerID string

param managementGroupID string
param subscriptionID string

@description('Construct resource names dynamically using `abbr`')
param resourceGroupName string = '${abbr}-rg'
param automationAccountName string = '${abbr}-aa'
param storageAccountName string
param runbookName string = '${abbr}-rb'
param scheduleName string = '${abbr}-sch'

param vnetName string = '${abbr}-vnet'
param snetName string = '${abbr}-snet'

param tags object = {
  createdby: 'bicep'
}

module resourceGroupModule '../modules/resource-group/resourceGroup.bicep' = {
  name: 'resourceGroupModule'
  scope: subscription(subscriptionID)
  params: {
    resourceGroupName: resourceGroupName
    locations: locations
    tags: tags
  }
}

module automationAccountModule '../modules/automation-account/automationAccount.bicep' = {
  name: 'automationAccountModule'
  scope: resourceGroup(subscriptionID, resourceGroupName)
  params: {
      locations: locations
      automationAccountName: automationAccountName
      runbookName: runbookName
      scheduleName: scheduleName
      tags: tags
  }
}

module roleAssignmentReaderModule '../modules/automation-account/roleAssignmentReader.bicep' = {
  name: 'roleAssignmentModule'
  scope: managementGroup(managementGroupID)
  params: {
    automationAccountId: automationAccountModule.outputs.automationAccountId
    automationAccountPrincipalId: automationAccountModule.outputs.automationAccountPrincipalId
    readerID: readerID
  }
}

module storageAccountModule '../modules/storage-account/storageAccount.bicep' = {
  name: 'storageAccountModule'
  scope: resourceGroup(subscriptionID, resourceGroupName)
  params: {
    storageAccountName: storageAccountName
    automationAccountName: automationAccountName
    automationAccountPrincipalId: automationAccountModule.outputs.automationAccountPrincipalId
    locations: locations
    storageBlobDataContributorID: storageBlobDataContributorID
    tags: tags
  }
}

module virtualNetworkModule '../modules/virtual-network/virtualNetwork.bicep' = {
  name: 'virtualNetworkModule'
  scope: resourceGroup(subscriptionID, resourceGroupName)
  params: {
    vnetName: vnetName
    snetName: snetName
    locations: locations
    tags: tags
  }
}
