param routeTableName string
param nextHopIp string


resource routeTableRoute1 'Microsoft.Network/routeTables/routes@2019-11-01' = {
  name: format('{0}/all-to-firewall', routeTableName)
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: nextHopIp
  }
}

