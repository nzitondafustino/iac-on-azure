var vnetName = 'hub-vnet'
var address = '10.0.0.0/16'
var subnets = ['default', 'AzureFirewallSubnet', 'GatewaySubnet', 'inbount-dns-subnet']

resource hubvnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        address
      ]
    }
    subnets: [ for i in range(0,4): {
        name: subnets[i]
        properties: union({
        addressPrefix: cidrSubnet(address, 24, i)
      }, subnets[i] == 'inbount-dns-subnet' ? {
        delegations: [
          {
            name: 'dnsResolverDelegation'
            properties: {
              serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
      } : {})
      }
    ]
  }
}


output vnetId string = hubvnet.id
output vnetName string = vnetName
output defaultSubnet string = hubvnet.properties.subnets[0].id
output firewallSubnet string = hubvnet.properties.subnets[1].id
output gatewaySubnet string = hubvnet.properties.subnets[2].id
output inbountDnsSubnet string = hubvnet.properties.subnets[3].id
