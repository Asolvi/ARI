param vnetName string
param snetName string
param locations string

param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: vnetName
  location: locations
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: ['10.5.0.0/16']
    }
    subnets: [
      {
        name: snetName
        properties: {
          addressPrefix: '10.5.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

output snetID string = vnet.properties.subnets[0].id
