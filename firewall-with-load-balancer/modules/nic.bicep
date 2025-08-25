param vmName string
param subNetId string
param nsgId string
param backEndPoolId string

var location = resourceGroup().location

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${vmName}-config'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subNetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: backEndPoolId
            }
          ]
        }
      }
    ]

    networkSecurityGroup: {
      id: nsgId
    }
  }
}

output nicId string = nic.id
output nicIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
