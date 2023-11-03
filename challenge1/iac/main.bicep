param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param userObjectId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: 'challenge1${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'challenge1x'
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    enableSoftDelete: false
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: userObjectId
        permissions: {
          secrets: [
            'list'
            'get'
            'set'
            'delete'
            'purge'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}


resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'challenge1'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.27.3'
    dnsPrefix: 'challenge1'
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
  }
}


output containerRegistryName string = containerRegistry.name

