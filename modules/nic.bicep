param vmName string 
param subnetId string
param nsgId string

var location = resourceGroup().location

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: format('{0}-nic', vmName)
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

output privateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output id string = nic.id
output nicName string = nic.name
