param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: 'challenge2acr'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'challenge2-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.27.3'
    dnsPrefix: 'challenge2'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
    ]
    addonProfiles: {
      httpApplicationRouting: {
        enabled: true
      }
    }
  }
}

// Give AKS the acrPull role in ACR.
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aks.id, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: acrPullRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

output containerRegistryName string = acr.name
