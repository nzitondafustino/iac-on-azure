
param subnetId string
param publicIp string
param publicIpIpAddress string
// param inboundPrivateIp string
param vmPrivateIps array
param destinationPorts array

// create firewall rules
//1. Network Rules

// create firewall
resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: 'fire-wall'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }   
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIp
          }
        }
      }
    ]
    // additionalProperties: {
    //   'Network.DNS.EnableProxy': 'true'
    //   'Network.DNS.Servers': format('{0},168.63.129.16,8.8.8.8', inboundPrivateIp)
    // }
    networkRuleCollections: [
      {
        name: 'alllow-spoke-to-spoke-and-spoke-to-internet'
        id: format('{0}/networkRuleCollections/alllow-spoke-to-spoke-and-spoke-to-internet', resourceId('Microsoft.Network/azureFirewalls', 'fire-wall'))
        properties: {
          priority: 200
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'alllow-spoke-to-spoke-and-spoke-to-internet'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                '10.0.0.0/8'
              ]
              destinationAddresses: [
                '*'
              ]
              sourceIpGroups: []
              destinationIpGroups: []
              destinationFqdns: []
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      }
    ]
    natRuleCollections: [ 
      {
        name: 'ssh'
        id: format('{0}/natRuleCollections/ssh', resourceId('Microsoft.Network/azureFirewalls', 'fire-wall'))
        properties: {
          priority: 200
          action: {
            type: 'Dnat'
          }
          rules: [for i in range(0,length(vmPrivateIps)): {
              name: format('vm{0}', i+1)
              protocols: [
                'TCP'
              ]
              translatedAddress: vmPrivateIps[i]
              translatedPort: '22'
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
              destinationAddresses: [
                publicIpIpAddress
              ]
              destinationPorts: [
                destinationPorts[i]
              ]
            }
          ]
        }
      }
    ]
  }
}


output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress

