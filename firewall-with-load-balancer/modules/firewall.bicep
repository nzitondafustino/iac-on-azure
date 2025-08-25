param firewallName string
param vmIps array
param ports array
param subnetId string
param loadbalancerIp string

var location = resourceGroup().location

// firewall IP
resource firewallIp 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: '${firewallName}-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}



resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: firewallName
  location: location
  properties: {
    applicationRuleCollections: []
    natRuleCollections: [
      {
        name: 'allow-ssh'
        properties: {
          priority: 200
          action: {
            type: 'Dnat'
          }
          rules: [ for i in range(0,length(vmIps)): {
              name: 'vm${i+1}-ssh'
              description: 'ssh into vm ${i + 1}'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                firewallIp.properties.ipAddress
              ]
              destinationPorts: [
                ports[i]
              ]
              protocols: [
                'TCP'
              ]
              translatedAddress: vmIps[i]
              translatedPort: '22'
            }
          ]
        }
      }
      {
        name: 'allow-web-traffic'
        properties: {
          priority: 201
          action: {
            type: 'Dnat'
          }
          rules: [
            {
              name: 'vms-traffic'
              description: 'allow vm backend apps'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                firewallIp.properties.ipAddress
              ]
              destinationPorts: [
                '80'
              ]
              protocols: [
                'TCP'
              ]
              translatedAddress: loadbalancerIp
              translatedPort: '80'
            }
          ]
        }
      }
    ]
    networkRuleCollections: []
    ipConfigurations: [
      {
        name: '${firewallName}-config'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: firewallIp.id
          }
        }
      }
    ]
  }
}
