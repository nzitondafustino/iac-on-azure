resource firewallIp 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'firewall-ip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

output firewallIpId string = firewallIp.id
output firewallIpAddress string = firewallIp.properties.ipAddress
